import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/models/search/unified_search_result.dart';
import 'package:nutricook/services/unified_search_service.dart';

final unifiedSearchServiceProvider = Provider<UnifiedSearchService>((ref) {
  return UnifiedSearchService();
});

class UnifiedSearchInput {
  const UnifiedSearchInput({
    required this.query,
    this.perTypeLimit = 40,
    this.maxResults = 60,
  });

  final String query;
  final int perTypeLimit;
  final int maxResults;

  @override
  bool operator ==(Object other) {
    return other is UnifiedSearchInput &&
        other.query == query &&
        other.perTypeLimit == perTypeLimit &&
        other.maxResults == maxResults;
  }

  @override
  int get hashCode => Object.hash(query, perTypeLimit, maxResults);
}

final unifiedSearchResultsProvider =
    FutureProvider.family<List<UnifiedSearchResult>, UnifiedSearchInput>((
      ref,
      input,
    ) {
      return ref
          .watch(unifiedSearchServiceProvider)
          .searchAll(
            input.query,
            perTypeLimit: input.perTypeLimit,
            maxResults: input.maxResults,
          );
    });
