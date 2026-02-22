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
  
  // Subcollections
  static const planner = 'planner';
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
  static const cuisine = ['italian', 'mexican', 'japanese', 'chinese', 'american'];
  static const dietary = ['vegetarian', 'vegan', 'gluten-free', 'dairy-free'];
  static const nutrition = ['low-carb', 'high-protein', 'low-fat', 'keto', 'paleo', 'whole30', 'low-calorie', 'high-fiber', 'high-carb', 'low-sugar'];
  
}