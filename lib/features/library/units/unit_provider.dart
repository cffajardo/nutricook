import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/models/unit/unit.dart';
import 'package:nutricook/services/unit_service.dart';

// Service provider
final unitServiceProvider = Provider<UnitService>((ref) {
  return UnitService();
});

// All units (cached reference data).
final unitsProvider = FutureProvider<List<Unit>>((ref) async {
  final service = ref.watch(unitServiceProvider);
  return service.getAllUnits();
});

// Single unit by id.
final unitByIdProvider =
    FutureProvider.family<Unit?, String>((ref, id) async {
  final service = ref.watch(unitServiceProvider);
  return service.getUnitById(id);
});

// Units grouped by type (weight, volume, count, etc.).
final unitsByTypeProvider =
    Provider<AsyncValue<Map<String, List<Unit>>>>((ref) {
  final unitsAsync = ref.watch(unitsProvider);

  return unitsAsync.whenData((units) {
    final map = <String, List<Unit>>{};
    for (final unit in units) {
      map.putIfAbsent(unit.type, () => <Unit>[]);
      map[unit.type]!.add(unit);
    }
    return map;
  });
});

// Units map for quick lookup: id -> Unit.
final unitsMapProvider = Provider<AsyncValue<Map<String, Unit>>>((ref) {
  final unitsAsync = ref.watch(unitsProvider);

  return unitsAsync.whenData((units) {
    return {for (final unit in units) unit.id: unit};
  });
});

