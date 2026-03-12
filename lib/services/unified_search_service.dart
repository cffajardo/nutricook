import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/constants.dart';
import 'package:nutricook/models/collection/collection.dart';
import 'package:nutricook/models/ingredient/ingredient.dart';
import 'package:nutricook/models/recipe/recipe.dart';
import 'package:nutricook/models/search/unified_search_result.dart';
import 'package:nutricook/models/techniques/techniques.dart';

class UnifiedSearchService {
  UnifiedSearchService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<List<UnifiedSearchResult>> searchAll(
    String query, {
    int perTypeLimit = 40,
    int maxResults = 60,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return const <UnifiedSearchResult>[];
    }

    final futures = await Future.wait<List<UnifiedSearchResult>>([
      _searchRecipes(normalizedQuery, perTypeLimit),
      _searchIngredients(normalizedQuery, perTypeLimit),
      _searchTechniques(normalizedQuery, perTypeLimit),
      _searchCollections(normalizedQuery, perTypeLimit),
    ]);

    final merged = <UnifiedSearchResult>[
      ...futures[0],
      ...futures[1],
      ...futures[2],
      ...futures[3],
    ];

    merged.sort((a, b) {
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return merged.take(maxResults).toList(growable: false);
  }

  Future<List<UnifiedSearchResult>> _searchRecipes(
    String query,
    int limit,
  ) async {
    final snapshot = await _db
        .collection(FirestoreConstants.recipes)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    final results = <UnifiedSearchResult>[];
    for (final doc in snapshot.docs) {
      try {
        final recipe = Recipe.fromJson(doc.data());
        final tags = recipe.tags.join(' ');
        final searchText = '${recipe.name} ${recipe.description} $tags';
        if (!_containsQuery(searchText, query)) {
          continue;
        }

        results.add(
          UnifiedSearchResult(
            type: UnifiedSearchType.recipe,
            id: recipe.id,
            title: recipe.name,
            subtitle: recipe.description,
            imageUrl: recipe.imageURL.isNotEmpty ? recipe.imageURL.first : null,
          ),
        );
      } catch (_) {
      }
    }
    return results;
  }

  Future<List<UnifiedSearchResult>> _searchIngredients(
    String query,
    int limit,
  ) async {
    final snapshot = await _db
        .collection(FirestoreConstants.ingredients)
        .orderBy('name')
        .limit(limit)
        .get();

    final results = <UnifiedSearchResult>[];
    for (final doc in snapshot.docs) {
      try {
        final ingredient = Ingredient.fromJson(doc.data());
        final searchText =
            '${ingredient.name} ${ingredient.category} ${ingredient.description ?? ''}';
        if (!_containsQuery(searchText, query)) {
          continue;
        }

        results.add(
          UnifiedSearchResult(
            type: UnifiedSearchType.ingredient,
            id: ingredient.id,
            title: ingredient.name,
            subtitle: ingredient.category,
            imageUrl: ingredient.imageURL,
          ),
        );
      } catch (_) {}
    }
    return results;
  }

  Future<List<UnifiedSearchResult>> _searchTechniques(
    String query,
    int limit,
  ) async {
    final snapshot = await _db
        .collection(FirestoreConstants.techniques)
        .orderBy('name')
        .limit(limit)
        .get();

    final results = <UnifiedSearchResult>[];
    for (final doc in snapshot.docs) {
      try {
        final technique = Technique.fromJson(doc.data());
        final searchText =
            '${technique.name} ${technique.category} ${technique.description ?? ''}';
        if (!_containsQuery(searchText, query)) {
          continue;
        }

        results.add(
          UnifiedSearchResult(
            type: UnifiedSearchType.technique,
            id: technique.id,
            title: technique.name,
            subtitle: technique.category,
            imageUrl: technique.imageURL.isNotEmpty
                ? technique.imageURL.first
                : null,
          ),
        );
      } catch (_) {}
    }
    return results;
  }

  Future<List<UnifiedSearchResult>> _searchCollections(
    String query,
    int limit,
  ) async {
    final snapshot = await _db
        .collection(FirestoreConstants.collections)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    final results = <UnifiedSearchResult>[];
    for (final doc in snapshot.docs) {
      try {
        final collection = Collection.fromJson(doc.data());
        final searchText = '${collection.name} ${collection.description}';
        if (!_containsQuery(searchText, query)) {
          continue;
        }

        results.add(
          UnifiedSearchResult(
            type: UnifiedSearchType.collection,
            id: collection.id,
            title: collection.name,
            subtitle: collection.description,
            imageUrl: collection.thumbnailUrl,
          ),
        );
      } catch (_) {}
    }
    return results;
  }

  bool _containsQuery(String text, String query) {
    return text.toLowerCase().contains(query);
  }
}
