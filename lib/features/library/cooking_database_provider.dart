import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/services/cooking_database_facade.dart';

final cookingDatabaseFacadeProvider =
    Provider<CookingDatabaseFacadeService>((ref) {
  return CookingDatabaseFacadeService();
});

