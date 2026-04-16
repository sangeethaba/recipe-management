// ================= RUN AFTER PAGE LOAD =================
window.addEventListener('DOMContentLoaded', () => {
  init();
});

let allRecipes = [];
let selectedIngredients = [];

function init() {
  loadRecipes();
  loadIngredients();

  // form listeners
  document.getElementById('ingredientForm').addEventListener('submit', addIngredientAPI);
  document.getElementById('recipeForm').addEventListener('submit', addRecipe);
}

// ================= LOAD RECIPES =================
async function loadRecipes() {
  const res = await fetch('/api/admin/my-recipes');
  const data = await res.json();

  allRecipes = data;

  const container = document.getElementById('recipesContainer');

  container.innerHTML = data.map((r, index) => `
    <div class="card recipe-card" data-index="${index}">
      <h4>${r.recipe_name}</h4>
      <p>${r.difficulty}</p>
    </div>
  `).join('');

  // 🔥 attach click AFTER render
  document.querySelectorAll('.recipe-card').forEach(card => {
    card.addEventListener('click', function () {
      const index = this.getAttribute('data-index');
      selectRecipe(index);
    });
  });
}

// ================= SELECT RECIPE =================
function selectRecipe(index) {
  console.log("CLICK WORKING:", index);

  const recipe = allRecipes[index];

  document.getElementById('selectedRecipe').innerHTML = `
    <h2>${recipe.recipe_name}</h2>
    <p>${recipe.instructions}</p>
  `;
}

// ================= LOAD INGREDIENTS =================
async function loadIngredients() {
  const res = await fetch('/api/ingredients');
  const data = await res.json();

  document.getElementById('ingredientSelect').innerHTML =
    data.map(i =>
      `<option value="${i.ingredient_id}">${i.ingredient_name}</option>`
    ).join('');
}

// ================= ADD INGREDIENT (UI) =================
function addIngredient() {
  const select = document.getElementById('ingredientSelect');
  const id = select.value;
  const name = select.selectedOptions[0].text;
  const quantity = document.getElementById('quantity').value;
  const unit = document.getElementById('unit').value;

  selectedIngredients.push({
    ingredient_id: parseInt(id),
    quantity: parseFloat(quantity),
    unit: unit
  });

  document.getElementById('ingredientList').innerHTML +=
    `<li>${name} - ${quantity} ${unit}</li>`;
}

// ================= ADD INGREDIENT API =================
async function addIngredientAPI(e) {
  e.preventDefault();

  const ingredient_name = document.getElementById('ingredientName').value;
  const category = document.getElementById('ingredientCategory').value;

  const res = await fetch('/api/admin/ingredients', {
    method: 'POST',
    headers: {'Content-Type':'application/json'},
    body: JSON.stringify({ ingredient_name, category })
  });

  const data = await res.json();

  if (data.success) {
    alert("Ingredient Added!");
    loadIngredients();
  }
}

// ================= ADD RECIPE =================
async function addRecipe(e) {
  e.preventDefault();

  const data = {
    name: document.getElementById('recipeName').value,
    difficulty: document.getElementById('difficulty').value,
    prep_time: document.getElementById('prepTime').value,
    cook_time: document.getElementById('cookTime').value,
    servings: document.getElementById('servings').value,
    instructions: document.getElementById('instructions').value,
    ingredients: selectedIngredients
  };

  const res = await fetch('/api/recipes', {
    method: 'POST',
    headers: {'Content-Type':'application/json'},
    body: JSON.stringify(data)
  });

  const result = await res.json();

  if (result.success) {
    alert("Recipe Added!");
    location.reload();
  }
}