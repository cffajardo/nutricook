import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/models/techniques/techniques.dart';
import 'package:nutricook/services/technique_service.dart';

// Service provider
final techniqueServiceProvider = Provider<TechniqueService>((ref) {
  return TechniqueService();
});

// All techniques (Cached)
final techniquesProvider = FutureProvider<List<Technique>>((ref) async {
  final service = ref.watch(techniqueServiceProvider);
  return service.getAllTechniques();
});

// Single technique by ID
final techniqueByIdProvider =
    FutureProvider.family<Technique?, String>((ref, id) async {
  final service = ref.watch(techniqueServiceProvider);
  return service.getTechniqueById(id);
});

