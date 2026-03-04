import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/models/techniques/techniques.dart';
import 'package:nutricook/services/technique_service.dart';

// Service provider
final techniqueServiceProvider = Provider<TechniqueService>((ref) {
  return TechniqueService();
});

// All techniques (cached reference data).
final techniquesProvider = FutureProvider<List<Technique>>((ref) async {
  final service = ref.watch(techniqueServiceProvider);
  return service.getAllTechniques();
});

// Single technique by id.
final techniqueByIdProvider =
    FutureProvider.family<Technique?, String>((ref, id) async {
  final service = ref.watch(techniqueServiceProvider);
  return service.getTechniqueById(id);
});

