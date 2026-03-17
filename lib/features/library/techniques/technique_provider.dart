import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/models/techniques/techniques.dart';
import 'package:nutricook/services/technique_service.dart';


final techniqueServiceProvider = Provider<TechniqueService>((ref) {
  return TechniqueService();
});

final techniquesProvider = FutureProvider<List<Technique>>((ref) async {
  final service = ref.watch(techniqueServiceProvider);
  return service.getAllTechniques();
});


