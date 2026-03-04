import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/models/nutrition/nutrition.dart';
import 'package:nutricook/services/nutrition_service.dart';

// Service provider
final nutritionServiceProvider = Provider<NutritionService>((ref) {
  return NutritionService();
});

// All nutrition metadata (cached reference data).
final nutritionDetailsProvider =
    FutureProvider<List<Nutrition>>((ref) async {
  final service = ref.watch(nutritionServiceProvider);
  return service.getAllNutritionDetails();
});

// Single nutrition metadata entry by id.
final nutritionDetailByIdProvider =
    FutureProvider.family<Nutrition?, String>((ref, id) async {
  final service = ref.watch(nutritionServiceProvider);
  return service.getNutritionDetailById(id);
});

