import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/services/cooking_database_facade.dart';

/// Provider exposing the cooking database facade service.
///
/// Features like recipes and planner can depend on this instead of
/// wiring individual ingredient/unit/technique/nutrition services.
final cookingDatabaseFacadeProvider =
    Provider<CookingDatabaseFacadeService>((ref) {
  return CookingDatabaseFacadeService();
});

