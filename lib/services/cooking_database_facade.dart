import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/unit/unit.dart';
import 'package:nutricook/models/techniques/techniques.dart';
import 'package:nutricook/models/nutrition/nutrition.dart' as nutrition_model;
import 'package:nutricook/services/ingredient_service.dart';
import 'package:nutricook/services/unit_service.dart';
import 'package:nutricook/services/technique_service.dart';
import 'package:nutricook/services/nutrition_service.dart';

/// Facade over the cooking reference database:
/// - Ingredients
/// - Units
/// - Techniques
/// - Nutrition metadata (RDVs)
///
/// This keeps cross‑feature code (recipes, planner, etc.)
/// from having to depend on each individual service.
class CookingDatabaseFacadeService {
  CookingDatabaseFacadeService({
    IngredientService? ingredientService,
    UnitService? unitService,
    TechniqueService? techniqueService,
    NutritionService? nutritionService,
  })  : _ingredientService = ingredientService ?? IngredientService(),
        _unitService = unitService ?? UnitService(),
        _techniqueService = techniqueService ?? TechniqueService(),
        _nutritionService = nutritionService ?? NutritionService();

  final IngredientService _ingredientService;
  final UnitService _unitService;
  final TechniqueService _techniqueService;
  final NutritionService _nutritionService;

  // ---------------------------------------------------------------------------
  // Ingredients
  // ---------------------------------------------------------------------------

  Future<List<Ingredient>> getAllIngredients() {
    return _ingredientService.getAllIngredients();
  }

  Future<Map<String, Ingredient>> getIngredientMap() async {
    final list = await getAllIngredients();
    return {for (final ing in list) ing.id: ing};
  }

  // ---------------------------------------------------------------------------
  // Units
  // ---------------------------------------------------------------------------

  Future<List<Unit>> getAllUnits() {
    return _unitService.getAllUnits();
  }

  Future<Map<String, Unit>> getUnitMap() async {
    final list = await getAllUnits();
    return {for (final unit in list) unit.id: unit};
  }

  // ---------------------------------------------------------------------------
  // Techniques
  // ---------------------------------------------------------------------------

  Future<List<Technique>> getAllTechniques() {
    return _techniqueService.getAllTechniques();
  }

  // ---------------------------------------------------------------------------
  // Nutrition (RDV metadata)
  // ---------------------------------------------------------------------------

  Future<List<nutrition_model.Nutrition>> getAllNutrition() {
    return _nutritionService.getAllNutritionDetails();
  }

  Future<Map<String, nutrition_model.Nutrition>> getNutritionMap() async {
    final list = await getAllNutrition();
    return {for (final n in list) n.id: n};
  }
}

