import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/services/cooking_database_facade.dart';

// Provider for Cooking DB Facade Service to aggregate access to all library data
// Mostly used for recipes and planner
final cookingDatabaseFacadeProvider =
    Provider<CookingDatabaseFacadeService>((ref) {
  return CookingDatabaseFacadeService();
});

