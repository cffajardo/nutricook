import 'package:nutricook/core/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SelectedCollectionIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null; 
  }

  void select(String id) {
    state = id;
  }

  void clear() {
    state = null;
  }
}

class CollectionSortNotifier extends Notifier<String> {
  @override
  String build() => CollectionSort.date;

  void setSort(String option) {
    state = option;
  }
}