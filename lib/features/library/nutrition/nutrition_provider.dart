import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/models/nutrition/nutrition.dart';
import 'package:nutricook/services/nutrition_service.dart';


final nutritionServiceProvider = Provider<NutritionService>((ref) {
  return NutritionService();
});


final nutritionDetailsProvider =
    FutureProvider<List<Nutrition>>((ref) async {
  final service = ref.watch(nutritionServiceProvider);
  return service.getAllNutritionDetails();
});




