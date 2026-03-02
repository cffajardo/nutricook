// ignore_for_file: unused_element

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';



class SearchQueryNotifier extends Notifier<String> {
  Timer? _debounceTimer;

  @override
  String build() => '';

  void setQuery(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      state = query;
    });
  }

  void clearQuery() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    state = '';
  }

  void _cancelTimer() {
    _debounceTimer?.cancel();
  }


} 

class SelectedTagsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void toggle(String tag) {
    if (state.contains(tag)) {
      state = state.where((t) => t != tag).toList();
    } else {
      state = [...state, tag];
    }
  }

  void clear() => state = [];
}

