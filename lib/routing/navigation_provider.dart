import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the active bottom navigation tab index.
/// 0: Recipes, 1: Planner, 2: Home, 3: Library, 4: Profile
final activeTabProvider = NotifierProvider<ActiveTabNotifier, int>(ActiveTabNotifier.new);

class ActiveTabNotifier extends Notifier<int> {
  @override
  int build() => 2; // Default to Home

  void setTab(int index) => state = index;
}
