class FirestoreConstants {
  // Collections
  static const users = 'users';
  static const recipes = 'recipes';
  static const ingredients = 'ingredients';
  static const techniques = 'techniques';
  static const units = 'units';
  static const nutrition = 'nutrition';
  static const collections = 'collections';
  static const media = 'media';
  static const recipeReports = 'recipeReports';
  static const categories = 'categories';
  static const tags = 'tags';
  static const notifications = 'notifications';

  // Subcollections
  static const plannerItems = 'plannerItems';
  static const favorites = 'favorites';
  static const items = 'items';
}

class IngredientCategory {
  static const vegetables = 'Vegetables';
  static const fruits = 'Fruits';
  static const dairy = 'Dairy';
  static const proteins = 'Proteins';
  static const fatsAndOils = 'Fats & Oils';
  static const grains = 'Grains';
  static const spices = 'Spices';
  static const herbs = 'Herbs';
  static const sauces = 'Sauces';
  static const seafood = 'Seafood';
  static const nutsAndSeeds = 'Nuts & Seeds';
  static const beverages = 'Beverages';
  static const custom = 'Custom';
}

class TechniqueCategory {
  static const cutting = 'Cutting';
  static const prep = 'Prep';
  static const dryHeat = 'Dry Heat';
  static const moistHeat = 'Moist Heat';
  static const combination = 'Combination';
  static const presentation = 'Presentation';
}

class RecipeTags {
  static const difficulty = ['easy', 'medium', 'hard'];
  static const cuisine = [
    'italian',
    'mexican',
    'japanese',
    'chinese',
    'american',
  ];
  static const dietary = ['vegetarian', 'vegan', 'gluten-free', 'dairy-free'];
  static const nutrition = [
    'low-carb',
    'high-protein',
    'low-fat',
    'keto',
    'paleo',
    'whole30',
    'low-calorie',
    'high-fiber',
    'high-carb',
    'low-sugar',
  ];
  static const custom = [];
}

class MealType {
  static const breakfast = 'Breakfast';
  static const lunch = 'Lunch';
  static const dinner = 'Dinner';
  static const snack = 'Snack';
}

class CollectionSort {
  static const date = 'Date Added';
  static const name = 'Name';
  static const recipeCount = 'Recipe Count';
}

class IngredientProcess {
  static const raw = 'Raw';
  static const chopped = 'Chopped';
  static const sliced = 'Sliced';
  static const diced = 'Diced';
  static const minced = 'Minced';
  static const grated = 'Grated';
  static const blended = 'Blended';
}
