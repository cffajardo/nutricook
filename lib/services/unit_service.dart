import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/unit/unit.dart';

/// Service for unit reference data + all gram conversion logic.
///
/// This is the single source of truth for:
/// - Storing / fetching units from Firestore.
/// - Converting arbitrary quantities to grams using unit metadata
///   and ingredient density / average weight.
class UnitService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Firestore access
  // ---------------------------------------------------------------------------

  Future<List<Unit>> getAllUnits() async {
    final snapshot = await _db
        .collection(FirestoreConstants.units)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => Unit.fromJson(doc.data()))
        .toList();
  }

  Future<Unit?> getUnitById(String unitId) async {
    final doc = await _db
        .collection(FirestoreConstants.units)
        .doc(unitId)
        .get();

    if (!doc.exists) return null;
    return Unit.fromJson(doc.data()!);
  }

  // ---------------------------------------------------------------------------
  // Gram conversion logic
  // ---------------------------------------------------------------------------

  /// Core conversion: quantity + unit (+ ingredient metadata) → grams.
  ///
  /// Handles three kinds of units:
  /// - `weight`: direct multiplier to grams (e.g. kg, oz).
  /// - `volume`: requires `ingredient.densityGPerMl` (e.g. cup, ml).
  /// - `count`: requires `ingredient.avgWeightG` (e.g. piece, egg).
  double convertToGrams({
    required double quantity,
    required Unit unit,
    required Ingredient ingredient,
  }) {
    switch (unit.type) {
      case 'weight':
        return _weightToGrams(quantity: quantity, unit: unit);
      case 'volume':
        return _volumeToGrams(
          quantity: quantity,
          unit: unit,
          ingredient: ingredient,
        );
      case 'count':
        return _countToGrams(
          quantity: quantity,
          ingredient: ingredient,
        );
      case 'energy':
        throw Exception(
          'Cannot convert energy units (kcal) to weight. '
          'Energy units are only for nutrition display.',
        );
      default:
        throw Exception('Unknown unit type: ${unit.type}');
    }
  }

  /// Weight units (g, kg, oz, lb, etc.) → grams.
  double _weightToGrams({
    required double quantity,
    required Unit unit,
  }) {
    return quantity * unit.multiplier;
  }

  /// Volume units (ml, L, cup, tbsp, etc.) → grams, using ingredient density.
  double _volumeToGrams({
    required double quantity,
    required Unit unit,
    required Ingredient ingredient,
  }) {
    if (ingredient.densityGPerMl == null) {
      throw Exception(
        'Cannot convert volume to weight: ${ingredient.name} is missing densityGPerMl. '
        'Please add density data to this ingredient.',
      );
    }

    final volumeInMl = quantity * unit.multiplier;
    return volumeInMl * ingredient.densityGPerMl!;
  }

  /// Count units (piece, clove, slice, etc.) → grams, using avgWeightG.
  double _countToGrams({
    required double quantity,
    required Ingredient ingredient,
  }) {
    if (ingredient.avgWeightG == null) {
      throw Exception(
        'Cannot convert count to weight: ${ingredient.name} is missing avgWeightG. '
        'Please add average weight data to this ingredient.',
      );
    }

    return quantity * ingredient.avgWeightG!;
  }
}

