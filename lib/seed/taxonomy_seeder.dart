import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutricook/core/constants.dart';

class TaxonomySeeder {
  static const String _difficultyCategoryId = 'difficulty';
  static const String _cuisineCategoryId = 'cuisine';
  static const String _dietaryCategoryId = 'dietary';
  static const String _nutritionCategoryId = 'nutrition';

  static Future<void> seed(FirebaseFirestore db) async {
    await seedCategories(db);
    await seedTags(db);
  }

  static Future<void> seedCategories(FirebaseFirestore db) async {
    final categories = <Map<String, dynamic>>[
      {'id': _difficultyCategoryId, 'name': 'Difficulty', 'parentId': null},
      {'id': _cuisineCategoryId, 'name': 'Cuisine', 'parentId': null},
      {'id': _dietaryCategoryId, 'name': 'Dietary', 'parentId': null},
      {'id': _nutritionCategoryId, 'name': 'Nutrition', 'parentId': null},
    ];

    final batch = db.batch();
    for (final category in categories) {
      batch.set(
        db
            .collection(FirestoreConstants.categories)
            .doc(category['id'] as String),
        {
          ...category,
          'isActive': true,
          'isSystem': true,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  static Future<void> seedTags(FirebaseFirestore db) async {
    final tags = <Map<String, dynamic>>[
      ...RecipeTags.difficulty.map(
        (tag) => _systemTag(tag: tag, categoryId: _difficultyCategoryId),
      ),
      ...RecipeTags.cuisine.map(
        (tag) => _systemTag(tag: tag, categoryId: _cuisineCategoryId),
      ),
      ...RecipeTags.dietary.map(
        (tag) => _systemTag(tag: tag, categoryId: _dietaryCategoryId),
      ),
      ...RecipeTags.nutrition.map(
        (tag) => _systemTag(tag: tag, categoryId: _nutritionCategoryId),
      ),
    ];

    final batch = db.batch();
    for (final tag in tags) {
      batch.set(
        db.collection(FirestoreConstants.tags).doc(tag['id'] as String),
        {
          ...tag,
          'isActive': true,
          'isSystem': true,
          'isUserGenerated': false,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  static Map<String, dynamic> _systemTag({
    required String tag,
    required String categoryId,
  }) {
    return {
      'id': tag,
      'name': tag,
      'categoryId': categoryId,
    };
  }
}
