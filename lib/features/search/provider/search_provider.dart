import 'package:nutricook/features/search/notifier/search_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchQueryNotifierProvider =
    NotifierProvider.autoDispose<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final selectedTagsProvider =
    NotifierProvider.autoDispose<SelectedTagsNotifier, List<String>>(
  SelectedTagsNotifier.new,
);