enum UnifiedSearchType { recipe, ingredient, technique, collection }

class UnifiedSearchResult {
  const UnifiedSearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });

  final UnifiedSearchType type;
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
}
