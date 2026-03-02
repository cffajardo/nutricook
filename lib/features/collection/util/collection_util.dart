import 'package:nutricook/models/collection/collection.dart';
import 'package:nutricook/models/collection_item/collection_item.dart';


bool isRecipeInCollection(Collection collection, String recipeId) {
  return collection.recipeCount > 0;
}

void reorderCollectionItems(List<CollectionItem> items) {
  items.sort((a, b) => a.order.compareTo(b.order));
}

Collection getCollectionWithItems(Collection collection, List<CollectionItem> items) {
  return collection.copyWith(recipeCount: items.length);
}