const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static('public'));

// ================= DB CONNECTION =================
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

const promisePool = pool.promise();

pool.getConnection((err, conn) => {
  if (err) {
    console.error("❌ DB CONNECTION FAILED:", err.message);
  } else {
    console.log("✅ DB CONNECTED SUCCESSFULLY");
    conn.release();
  }
});

// ================= REGISTER =================
app.post('/api/auth/register', async (req, res) => {
  const { username, email, password, user_role } = req.body;

  try {
    await promisePool.query(
      'INSERT INTO user (username, email, password, user_role) VALUES (?, ?, ?, ?)',
      [username, email, password, user_role]
    );

    res.json({ success: true });
  } catch (err) {
    console.error("REGISTER ERROR:", err);
    res.status(500).json({ success: false, error: 'Registration failed' });
  }
});

// ================= LOGIN =================
app.post('/api/auth/login', async (req, res) => {
  const { username_or_email } = req.body;

  try {
    const [rows] = await promisePool.query(
      'SELECT * FROM user WHERE username = ? OR email = ?',
      [username_or_email, username_or_email]
    );

    if (rows.length === 0) {
      return res.json({ success: false, error: 'Invalid login' });
    }

    const user = rows[0];

    res.json({
      success: true,
      user: {
        user_id: user.user_id,
        username: user.username,
        email: user.email,
        user_role: user.user_role
      }
    });

  } catch (err) {
    console.error("LOGIN ERROR:", err);
    res.json({ success: false, error: 'Server error' });
  }
});

/// ================= ADD RECIPE (FINAL FIX) =================
app.post('/api/recipes', async (req, res) => {
  const {
    name,
    difficulty,
    prep_time,
    cook_time,
    servings,
    instructions,
    ingredients
  } = req.body;

  try {
    const [result] = await promisePool.query(
      `INSERT INTO recipe 
      (recipe_name, difficulty, prep_time, cook_time, servings, instructions)
      VALUES (?, ?, ?, ?, ?, ?)`,
      [name, difficulty, prep_time, cook_time, servings, instructions]
    );

    const recipeId = result.insertId;

    for (let item of ingredients) {
      await promisePool.query(
        `INSERT INTO recipe_ingredient 
        (recipe_id, ingredient_id, quantity, unit)
        VALUES (?, ?, ?, ?)`,
        [recipeId, item.ingredient_id, item.quantity, item.unit]
      );
    }

    res.json({ success: true });

  } catch (err) {
    console.error("❌ ADD RECIPE ERROR:", err);
    res.json({ success: false, error: err.message });
  }
});

// ================= ADMIN RECIPES =================
app.get('/api/admin/my-recipes', async (req, res) => {
  try {
    const [rows] = await promisePool.query(`
      SELECT r.*, u.username AS chef_name
      FROM recipe r
      LEFT JOIN user u ON r.created_by = u.user_id
    `);
    res.json(rows);
  } catch (err) {
    console.error("ADMIN RECIPES ERROR:", err);
    res.status(500).json({ error: 'Failed to load recipes' });
  }
});
// ================= ADD RECIPE =================
app.post('/api/recipes', async (req, res) => {
  const {
    name,
    difficulty,
    prep_time,
    cook_time,
    servings,
    cuisine,
    instructions,
    ingredients
  } = req.body;

  try {
    // 👉 insert recipe
    const [result] = await promisePool.query(
      `INSERT INTO recipe 
      (recipe_name, difficulty, prep_time, cook_time, servings, cuisine, instructions, created_by)
      VALUES (?, ?, ?, ?, ?, ?, ?, 1)`,
      [name, difficulty, prep_time, cook_time, servings, cuisine, instructions]
    );

    const recipeId = result.insertId;

    // 👉 insert ingredients linking
    for (let item of ingredients) {
      await promisePool.query(
        `INSERT INTO recipe_ingredient 
        (recipe_id, ingredient_id, quantity, unit)
        VALUES (?, ?, ?, ?)`,
        [recipeId, item.ingredient_id, item.quantity, item.unit]
      );
    }

    res.json({ success: true });

  } catch (err) {
    console.error("ADD RECIPE ERROR:", err);
    res.json({ success: false });
  }
});

// ================= LEADERBOARD =================
app.get('/api/leaderboard/admins', async (req, res) => {
  try {
    const [rows] = await promisePool.query(`
      SELECT 
        u.username,
        COUNT(r.recipe_id) AS recipe_count,
        IFNULL(AVG(r.avg_rating), 0) AS avg_admin_rating
      FROM user u
      LEFT JOIN recipe r ON u.user_id = r.created_by
      WHERE u.user_role = 'admin'
      GROUP BY u.user_id
      ORDER BY recipe_count DESC
    `);

    res.json(rows);
  } catch (err) {
    console.error("LEADERBOARD ERROR:", err);
    res.status(500).json({ error: 'Failed to load leaderboard' });
  }
});

// ================= ADD RECIPE (FINAL FIX) =================
app.post('/api/recipes', async (req, res) => {
  const {
    name,
    difficulty,
    prep_time,
    cook_time,
    servings,
    instructions,
    ingredients
  } = req.body;

  try {
    // 🔥 IMPORTANT: match column names EXACTLY
    const [result] = await promisePool.query(
      `INSERT INTO recipe 
      (recipe_name, difficulty, prep_time, cook_time, servings, instructions)
      VALUES (?, ?, ?, ?, ?, ?)`,
      [name, difficulty, prep_time, cook_time, servings, instructions]
    );

    const recipeId = result.insertId;

    // 🔗 insert ingredients
    for (let item of ingredients) {
      await promisePool.query(
        `INSERT INTO recipe_ingredient 
        (recipe_id, ingredient_id, quantity, unit)
        VALUES (?, ?, ?, ?)`,
        [recipeId, item.ingredient_id, item.quantity, item.unit]
      );
    }

    res.json({ success: true });

  } catch (err) {
    console.error("❌ ADD RECIPE ERROR FULL:", err);
    res.json({ success: false, error: err.message });
  }
});

// ================= TEST =================
app.get('/test', (req, res) => {
  res.send("Server working!");
});

// ================= START =================
app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});