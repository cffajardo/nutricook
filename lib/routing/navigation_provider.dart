import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeTabProvider = NotifierProvider<ActiveTabNotifier, int>(ActiveTabNotifier.new);

class ActiveTabNotifier extends Notifier<int> {
  @override
  int build() => 2; // Default to Home

  void setTab(int index) => state = index;
}
