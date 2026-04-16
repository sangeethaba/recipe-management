CREATE DATABASE IF NOT EXISTS cookbook1;
USE cookbook1;

DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS recipe_ingredient;
DROP TABLE IF EXISTS ingredient;
DROP TABLE IF EXISTS recipe;
DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS leaderboard;

DROP FUNCTION IF EXISTS get_avg_rating;
DROP FUNCTION IF EXISTS get_review_count;
DROP FUNCTION IF EXISTS adjust_quantity;
DROP PROCEDURE IF EXISTS update_leaderboard;

CREATE TABLE user (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    user_role ENUM('admin', 'user') DEFAULT 'user',
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    password VARCHAR(255) NOT NULL,
    CHECK (LENGTH(username) >= 3)
);

CREATE TABLE recipe (
    recipe_id INT PRIMARY KEY AUTO_INCREMENT,
    recipe_name VARCHAR(100) NOT NULL,
    difficulty ENUM('Easy', 'Medium', 'Hard') DEFAULT 'Medium',
    prep_time INT CHECK (prep_time > 0),
    cook_time INT CHECK (cook_time >= 0),
    servings INT DEFAULT 1 CHECK (servings > 0),
    instructions TEXT,
    cuisine_type ENUM('Italian','Chinese','Indian','Mexican','American','French','British','Other') DEFAULT 'Other',
    avg_rating DECIMAL(3,2) DEFAULT 0 CHECK (avg_rating BETWEEN 0 AND 5),
    review_count INT DEFAULT 0,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_recipe_creator FOREIGN KEY (created_by) REFERENCES user(user_id) ON DELETE SET NULL
);

CREATE TABLE ingredient (
    ingredient_id INT PRIMARY KEY AUTO_INCREMENT,
    ingredient_name VARCHAR(100) NOT NULL UNIQUE,
    category ENUM('Vegetable','Fruit','Dairy','Meat','Grain','Spice','Other') DEFAULT 'Other'
);

CREATE TABLE recipe_ingredient (
    recipe_id INT,
    ingredient_id INT,
    quantity DECIMAL(10,2) NOT NULL,
    unit ENUM('g','kg','ml','l','cup','tbsp','tsp','piece','pinch') DEFAULT 'piece',
    PRIMARY KEY (recipe_id, ingredient_id),
    CONSTRAINT fk_ri_recipe FOREIGN KEY (recipe_id) REFERENCES recipe(recipe_id) ON DELETE CASCADE,
    CONSTRAINT fk_ri_ingredient FOREIGN KEY (ingredient_id) REFERENCES ingredient(ingredient_id) ON DELETE CASCADE
);

CREATE TABLE review (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    recipe_id INT NOT NULL,
    user_id INT NOT NULL,
    rating DECIMAL(3,2) CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_helpful BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_review_recipe FOREIGN KEY (recipe_id) REFERENCES recipe(recipe_id) ON DELETE CASCADE,
    CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_recipe (user_id, recipe_id)
);

CREATE TABLE leaderboard (
    rank_position INT PRIMARY KEY,
    chef_id INT UNIQUE,
    chef_username VARCHAR(50),
    total_recipes INT,
    avg_rating DECIMAL(3,2),
    total_reviews INT,
    CONSTRAINT fk_leaderboard_chef FOREIGN KEY (chef_id) REFERENCES user(user_id)
);

INSERT INTO user (username, email, user_role, password) VALUES
('gordon_ramsay', 'gordon@cookbook.com', 'admin', ''),
('sanjeev_kapoor', 'sanjeev@cookbook.com', 'admin', ''),
('jamie_oliver', 'jamie@cookbook.com', 'admin', ''),
('john_doe', 'john@email.com', 'user', ''),
('jane_smith', 'jane@email.com', 'user', ''),
('mike_wilson', 'mike@email.com', 'user', ''),
('sarah_jones', 'sarah@email.com', 'user', '');

INSERT INTO recipe (recipe_name, difficulty, prep_time, cook_time, servings, instructions, cuisine_type, created_by) VALUES
-- Gordon Ramsay's 10 recipes
('Spaghetti Carbonara','Medium',15,20,4,'Cook spaghetti. Fry bacon. Mix eggs + Parmesan. Toss.','Italian', (SELECT user_id FROM user WHERE username='gordon_ramsay')),
('Margherita Pizza','Hard',30,15,2,'Prepare dough. Add sauce, cheese, basil. Bake.','Italian', (SELECT user_id FROM user WHERE username='gordon_ramsay')),
('Beef Wellington','Hard',60,45,4,'Sear beef, wrap with duxelles and pastry, then bake.','British', (SELECT user_id FROM user WHERE username='gordon_ramsay')),
('Scrambled Eggs','Easy',5,5,2,'Slowly cook eggs with butter, stirring constantly.','British', (SELECT user_id FROM user WHERE username='gordon_ramsay')),
('Lobster Risotto','Hard',40,30,4,'Cook risotto, add lobster and seasoning.','Italian', (SELECT user_id FROM user WHERE username='gordon_ramsay')),
('Pan Seared Scallops','Medium',15,10,2,'Sear scallops in butter, season well.','French', (SELECT user_id FROM user WHERE username='gordon_ramsay')),
('Beef Stroganoff','Medium',30,25,4,'Cook beef with mushrooms and cream sauce.','Other', (SELECT user_id FROM user WHERE username='gordon_ramsay')),
('Sticky Toffee Pudding','Medium',20,40,6,'Bake pudding, cover in toffee sauce.','British', (SELECT user_id FROM user WHERE username='gordon_ramsay')),
('Roast Chicken','Easy',20,60,4,'Roast whole chicken seasoned with herbs.','British', (SELECT user_id FROM user WHERE username='gordon_ramsay')),
('Caesar Dressing','Easy',10,0,4,'Mix anchovies, garlic, mustard, lemon.','American', (SELECT user_id FROM user WHERE username='gordon_ramsay')),

-- Sanjeev Kapoor's 10 recipes
('Butter Chicken','Medium',20,30,4,'Marinate chicken. Cook with butter + tomato. Add cream.','Indian', (SELECT user_id FROM user WHERE username='sanjeev_kapoor')),
('Tacos al Pastor','Easy',15,10,4,'Grill marinated pork. Serve with pineapple.','Mexican', (SELECT user_id FROM user WHERE username='sanjeev_kapoor')),
('Palak Paneer','Medium',25,20,4,'Blanch spinach, cook with spices and paneer cubes.','Indian', (SELECT user_id FROM user WHERE username='sanjeev_kapoor')),
('Dal Makhani','Medium',30,45,6,'Slow-cooked black lentils with cream and butter.','Indian', (SELECT user_id FROM user WHERE username='sanjeev_kapoor')),
('Chole Bhature','Medium',30,40,4,'Cook chickpeas, fry bhature bread.','Indian', (SELECT user_id FROM user WHERE username='sanjeev_kapoor')),
('Masala Dosa','Hard',60,30,4,'Prepare dosa batter, cook with potato filling.','Indian', (SELECT user_id FROM user WHERE username='sanjeev_kapoor')),
('Chicken Biryani','Hard',60,60,6,'Layer marinated chicken and rice, cook thoroughly.','Indian', (SELECT user_id FROM user WHERE username='sanjeev_kapoor')),
('Rogan Josh','Medium',35,45,4,'Cook lamb with yogurt and spices.','Indian', (SELECT user_id FROM user WHERE username='sanjeev_kapoor')),
('Gulab Jamun','Medium',20,30,10,'Fry milk dough balls in syrup.','Indian', (SELECT user_id FROM user WHERE username='sanjeev_kapoor')),
('Paneer Tikka','Easy',25,15,4,'Grill marinated paneer cubes.','Indian', (SELECT user_id FROM user WHERE username='sanjeev_kapoor')),

-- Jamie Oliver's 10 recipes
('Chocolate Lava Cake','Hard',20,12,2,'Mix chocolate batter. Bake.','French', (SELECT user_id FROM user WHERE username='jamie_oliver')),
('Caesar Salad','Easy',15,0,2,'Mix lettuce, dressing, croutons.','American', (SELECT user_id FROM user WHERE username='jamie_oliver')),
('Pesto Pasta','Easy',15,10,2,'Cook pasta and toss with fresh basil pesto.','Italian', (SELECT user_id FROM user WHERE username='jamie_oliver')),
('Veggie Stir Fry','Easy',10,10,3,'Stir fry mixed vegetables with soy sauce and garlic.','Chinese', (SELECT user_id FROM user WHERE username='jamie_oliver')),
('Fish and Chips','Easy',30,25,4,'Fry battered fish, serve with chips.','British', (SELECT user_id FROM user WHERE username='jamie_oliver')),
('Chicken Caesar Wrap','Easy',15,0,2,'Wrap Caesar salad with grilled chicken.','American', (SELECT user_id FROM user WHERE username='jamie_oliver')),
('Pumpkin Soup','Easy',20,30,4,'Cook pumpkin, blend and season.','Other', (SELECT user_id FROM user WHERE username='jamie_oliver')),
('Mushroom Risotto','Medium',30,30,4,'Cook risotto with mushrooms and stock.','Italian', (SELECT user_id FROM user WHERE username='jamie_oliver')),
('Apple Crumble','Medium',20,40,6,'Bake apples with crumble topping.','British', (SELECT user_id FROM user WHERE username='jamie_oliver')),
('BBQ Ribs','Medium',40,60,4,'Slow cook ribs with BBQ sauce.','American', (SELECT user_id FROM user WHERE username='jamie_oliver'));

-- Ingredients list
INSERT INTO ingredient (ingredient_name, category) VALUES
('Spaghetti','Grain'), ('Bacon','Meat'), ('Eggs','Dairy'), ('Parmesan Cheese','Dairy'),
('Tomato Sauce','Vegetable'),('Mozzarella','Dairy'),('Basil','Spice'),
('Chicken','Meat'),('Butter','Dairy'),('Cream','Dairy'),
('Pork','Meat'),('Pineapple','Fruit'),('Tortillas','Grain'),
('Chocolate','Other'),('Flour','Grain'),('Lettuce','Vegetable'),
('Scallops','Meat'),('Mushrooms','Vegetable'),('Beef','Meat'),('Lentils','Grain'),
('Spinach','Vegetable'),('Paneer','Dairy'), ('Tomato','Vegetable'),('Onion','Vegetable'),
('Garlic','Spice'),('Milk','Dairy'),('Yogurt','Dairy'),('Sugar','Other'),
('Rice','Grain'), ('Honey','Other'), ('Apple','Fruit'), ('Rib Meat','Meat');

-- Recipe ingredients, linking recipes and ingredients with quantity/unit

INSERT INTO recipe_ingredient (recipe_id, ingredient_id, quantity, unit) VALUES
-- Spaghetti Carbonara (recipe_id=1)
(1, 1, 400, 'g'), -- Spaghetti
(1, 2, 200, 'g'), -- Bacon
(1, 3, 4, 'piece'), -- Eggs
(1, 4, 100, 'g'), -- Parmesan Cheese

-- Margherita Pizza (2)
(2, 5, 200, 'g'), -- Tomato Sauce
(2, 6, 150, 'g'), -- Mozzarella
(2, 7, 10, 'piece'), -- Basil

-- Beef Wellington (3)
(3, 19, 500, 'g'), -- Beef
(3, 20, 200, 'g'), -- Mushrooms (duxelles)
(3, 14, 250, 'g'), -- Flour (pastry)

-- Scrambled Eggs (4)
(4, 3, 4, 'piece'), -- Eggs
(4, 9, 50, 'g'), -- Butter

-- Lobster Risotto (5)
(5, 21, 400, 'g'), -- Rice
(5, 3, 100, 'ml'), -- Cream

-- Pan Seared Scallops (6)
(6, 16, 20, 'piece'), -- Scallops
(6, 9, 30, 'g'), -- Butter

-- Beef Stroganoff (7)
(7, 19, 400, 'g'), -- Beef
(7, 20, 150, 'g'), -- Mushrooms
(7, 10, 100, 'ml'), -- Cream

-- Sticky Toffee Pudding (8)
(8, 14, 200, 'g'), -- Flour
(8, 31, 150, 'g'), -- Sugar
(8, 9, 100, 'g'), -- Butter
(8, 3, 3, 'piece'), -- Eggs
(8, 24, 100, 'ml'), -- Milk
(8, 32, 50, 'ml'), -- Honey

-- Roast Chicken (9)
(9, 8, 1200, 'g'), -- Chicken
(9, 9, 50, 'g'), -- Butter
(9, 33, 3, 'clove'), -- Garlic
(9, 7, 5, 'piece'), -- Basil

-- Caesar Dressing (10)
(10, 33, 1, 'clove'), -- Garlic
(10, 9, 30, 'g'), -- Butter
(10, 3, 1, 'piece'), -- Eggs
(10, 4, 50, 'g'), -- Parmesan Cheese

-- Butter Chicken (11)
(11, 8, 500, 'g'), -- Chicken
(11, 9, 100, 'g'), -- Butter
(11, 34, 150, 'g'), -- Tomato
(11, 10, 100, 'ml'), -- Cream
(11, 33, 2, 'clove'), -- Garlic

-- Tacos al Pastor (12)
(12, 11, 400, 'g'), -- Pork
(12, 12, 80, 'g'), -- Pineapple
(12, 13, 8, 'piece'), -- Tortillas

-- Palak Paneer (13)
(13, 21, 300, 'g'), -- Spinach
(13, 22, 200, 'g'), -- Paneer
(13, 34, 100, 'g'), -- Tomato
(13, 33, 2, 'clove'), -- Garlic

-- Dal Makhani (14)
(14, 25, 250, 'g'), -- Lentils
(14, 9, 80, 'g'), -- Butter
(14, 10, 100, 'ml'), -- Cream
(14, 33, 2, 'clove'), -- Garlic

-- Chole Bhature (15)
(15, 25, 300, 'g'), -- Lentils (chickpeas)
(15, 14, 250, 'g'), -- Flour
(15, 34, 100, 'g'), -- Tomato

-- Masala Dosa (16)
(16, 21, 200, 'g'), -- Rice
(16, 25, 100, 'g'), -- Lentils
(16, 35, 150, 'g'), -- Potato (needs to be inserted in ingredient table)

-- Chicken Biryani (17)
(17, 8, 500, 'g'), -- Chicken
(17, 21, 300, 'g'), -- Rice
(17, 36, 100, 'ml'), -- Yogurt

-- Rogan Josh (18)
(18, 19, 400, 'g'), -- Beef (or lamb substitute)
(18, 36, 150, 'ml'), -- Yogurt

-- Gulab Jamun (19)
(19, 14, 200, 'g'), -- Flour
(19, 24, 100, 'ml'), -- Milk
(19, 31, 300, 'g'), -- Sugar

-- Paneer Tikka (20)
(20, 22, 250, 'g'), -- Paneer
(20, 7, 10, 'g'), -- Spice (generic)

-- Chocolate Lava Cake (21)
(21, 15, 200, 'g'), -- Chocolate
(21, 3, 3, 'piece'), -- Eggs
(21, 14, 150, 'g'), -- Flour
(21, 9, 100, 'g'), -- Butter
(21, 31, 100, 'g'), -- Sugar

-- Caesar Salad (22)
(22, 16, 200, 'g'), -- Lettuce
(22, 4, 50, 'g'), -- Parmesan Cheese
(22, 9, 30, 'g'), -- Butter

-- Pesto Pasta (23)
(23, 1, 200, 'g'), -- Spaghetti (reuse ingredient_id 1)
(23, 7, 20, 'g'), -- Basil
(23, 4, 50, 'g'), -- Parmesan Cheese

-- Veggie Stir Fry (24)
(24, 20, 150, 'g'), -- Mushrooms
(24, 34, 1, 'piece'), -- Onion
(24, 33, 2, 'clove'), -- Garlic

-- Fish and Chips (25)
(25, 37, 400, 'g'), -- Rib Meat (substitute for fish, ingredient_id needs confirmation)
(25, 14, 200, 'g'), -- Flour
(25, 38, 300, 'g'), -- Potato (make sure 'Potato' ingredient added, with new ingredient_id)

-- Chicken Caesar Wrap (26)
(26, 8, 200, 'g'), -- Chicken
(26, 16, 100, 'g'), -- Lettuce
(26, 13, 2, 'piece'), -- Tortillas

-- Pumpkin Soup (27)
(27, 39, 500, 'g'), -- Pumpkin (add 'Pumpkin' to ingredient table)
(27, 10, 100, 'ml'), -- Cream

-- Mushroom Risotto (28)
(28, 21, 300, 'g'), -- Rice
(28, 20, 150, 'g'), -- Mushrooms
(28, 9, 50, 'g'), -- Butter

-- Apple Crumble (29)
(29, 40, 400, 'g'), -- Apple (add 'Apple' if missing)
(29, 14, 150, 'g'), -- Flour
(29, 31, 100, 'g'), -- Sugar

-- BBQ Ribs (30)
(30, 37, 500, 'g'), -- Rib Meat
(30, 41, 150, 'ml'); -- BBQ Sauce (add 'BBQ Sauce' to ingredient table)


-- For other recipes add ingredients as needed similarly...

-- Sample reviews for some recipes
INSERT INTO review (recipe_id, user_id, rating, comment) VALUES
(1, (SELECT user_id FROM user WHERE username='john_doe'), 4.5, 'Delicious!'),
(1, (SELECT user_id FROM user WHERE username='jane_smith'), 4.0, 'Nice taste'),
(2, (SELECT user_id FROM user WHERE username='mike_wilson'), 5.0, 'Perfect Pizza'),
(3, (SELECT user_id FROM user WHERE username='sarah_jones'), 4.8, 'Excellent dish!'),
(10, (SELECT user_id FROM user WHERE username='john_doe'), 4.2, 'Very fresh');

DELIMITER //

CREATE FUNCTION get_avg_rating(recipeId INT)
RETURNS DECIMAL(3,2)
DETERMINISTIC
BEGIN
  DECLARE ar DECIMAL(3,2);
  SELECT AVG(rating) INTO ar FROM review WHERE recipe_id = recipeId;
  RETURN IFNULL(ar, 0);
END //

CREATE FUNCTION get_review_count(recipeId INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE rc INT;
  SELECT COUNT(*) INTO rc FROM review WHERE recipe_id = recipeId;
  RETURN IFNULL(rc, 0);
END //

CREATE FUNCTION adjust_quantity(qty DECIMAL(10,2), old_serv INT, new_serv INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  RETURN (qty * new_serv) / old_serv;
END //

CREATE PROCEDURE get_recipe_full_details(IN p_recipe_id INT)
BEGIN
  -- 1) Recipe details
  SELECT r.recipe_id,
         r.recipe_name,
         r.difficulty,
         r.prep_time,
         r.cook_time,
         r.servings,
         r.instructions,
         r.cuisine_type,
         r.avg_rating,
         r.review_count,
         u.user_id     AS chef_id,
         u.username    AS chef_name,
         r.created_at,
         r.updated_at
  FROM recipe r
  LEFT JOIN user u ON r.created_by = u.user_id
  WHERE r.recipe_id = p_recipe_id;

  -- 2) Ingredients
  SELECT i.ingredient_id,
         i.ingredient_name,
         i.category,
         ri.quantity,
         ri.unit
  FROM recipe_ingredient ri
  JOIN ingredient i ON ri.ingredient_id = i.ingredient_id
  WHERE ri.recipe_id = p_recipe_id;

  -- 3) Reviews
  SELECT rv.review_id,
         rv.recipe_id,
         rv.user_id,
         usr.username,
         rv.rating,
         rv.comment,
         rv.review_date,
         rv.is_helpful
  FROM review rv
  JOIN user usr ON rv.user_id = usr.user_id
  WHERE rv.recipe_id = p_recipe_id
  ORDER BY rv.review_date DESC;
END //

CREATE PROCEDURE update_leaderboard()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE cid INT;
  DECLARE cusername VARCHAR(50);
  DECLARE total_recipes INT;
  DECLARE avg_rating DECIMAL(3,2);
  DECLARE total_reviews INT;

  DECLARE cur CURSOR FOR 
    SELECT u.user_id, u.username, COUNT(r.recipe_id), IFNULL(ROUND(AVG(r.avg_rating),2),0), IFNULL(SUM(r.review_count),0)
    FROM user u
    LEFT JOIN recipe r ON u.user_id = r.created_by
    WHERE u.user_role = 'admin'
    GROUP BY u.user_id
    ORDER BY avg_rating DESC, total_reviews DESC;
    
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  DELETE FROM leaderboard;
  SET @rank := 0;

  OPEN cur;

  read_loop: LOOP
    FETCH cur INTO cid, cusername, total_recipes, avg_rating, total_reviews;
    IF done THEN
      LEAVE read_loop;
    END IF;
    SET @rank := @rank + 1;
    INSERT INTO leaderboard(rank_position, chef_id, chef_username, total_recipes, avg_rating, total_reviews)
    VALUES(@rank, cid, cusername, total_recipes, avg_rating, total_reviews);
  END LOOP;

  CLOSE cur;
END //

CREATE TRIGGER after_review_insert
AFTER INSERT ON review
FOR EACH ROW
BEGIN
  UPDATE recipe
  SET avg_rating = get_avg_rating(NEW.recipe_id), review_count = get_review_count(NEW.recipe_id)
  WHERE recipe_id = NEW.recipe_id;
  CALL update_leaderboard();
END //

CREATE TRIGGER after_review_update
AFTER UPDATE ON review
FOR EACH ROW
BEGIN
  UPDATE recipe
  SET avg_rating = get_avg_rating(NEW.recipe_id), review_count = get_review_count(NEW.recipe_id)
  WHERE recipe_id = NEW.recipe_id;
  CALL update_leaderboard();
END //

CREATE TRIGGER after_review_delete
AFTER DELETE ON review
FOR EACH ROW
BEGIN
  UPDATE recipe
  SET avg_rating = get_avg_rating(OLD.recipe_id), review_count = get_review_count(OLD.recipe_id)
  WHERE recipe_id = OLD.recipe_id;
  CALL update_leaderboard();
END //

DELIMITER ;

-- Initialize leaderboard once
CALL update_leaderboard();
