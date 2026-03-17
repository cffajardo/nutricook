import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/collection/provider/collection_provider.dart';
import 'package:nutricook/models/collection/collection.dart';
import 'package:nutricook/services/collection_item_service.dart';

class AddToCollectionsModal extends ConsumerStatefulWidget {
  final String recipeId;
  final String recipeName;
  final String? thumbnailUrl;
  final List<String>? tags;
  final int prepTime;
  final int cookTime;
  final bool isRecipeLiked;

  const AddToCollectionsModal({
    super.key,
    required this.recipeId,
    required this.recipeName,
    this.thumbnailUrl,
    this.tags,
    this.prepTime = 0,
    this.cookTime = 0,
    this.isRecipeLiked = false,
  });

  @override
  ConsumerState<AddToCollectionsModal> createState() =>
      _AddToCollectionsModalState();
}

class _AddToCollectionsModalState extends ConsumerState<AddToCollectionsModal> {
  final Set<String> _selectedCollectionIds = {};
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _initializeSelectedCollections();
  }

  void _initializeSelectedCollections() {
    final collectionsAsync = ref.read(userCollectionsProvider);
    collectionsAsync.whenData((collections) {
      if (widget.isRecipeLiked) {
        try {
          final favoritesCollection = collections.firstWhere(
            (c) => c.isDefault,
          );
          setState(() {
            _selectedCollectionIds.add(favoritesCollection.id);
          });
        } catch (e) {
          // Favorites collection not found
        }
      }
    });
  }

  Future<void> _addToSelectedCollections() async {
    if (_selectedCollectionIds.isEmpty) {
      _showError('Please select at least one collection');
      return;
    }

    setState(() => _isAdding = true);

    try {
      final service = CollectionItemService();

      await Future.wait(
        _selectedCollectionIds.map((collectionId) {
          return service.addItemToCollection(
            collectionId: collectionId,
            recipeId: widget.recipeId,
            recipeName: widget.recipeName,
            thumbnailUrl: widget.thumbnailUrl,
            tags: widget.tags,
            prepTime: widget.prepTime,
            cookTime: widget.cookTime,
          );
        }),
      );

      if (!mounted) return;

      final collectionsAsync = ref.read(userCollectionsProvider);
      collectionsAsync.whenData((collections) {
        final selectedCollectionNames = collections
            .where((c) => _selectedCollectionIds.contains(c.id))
            .map((c) => c.name)
            .join(', ');

        _showSuccess(
          'Added to ${_selectedCollectionIds.length} collection${_selectedCollectionIds.length > 1 ? 's' : ''}: $selectedCollectionNames',
        );

        if (mounted) {
          Navigator.pop(context, _selectedCollectionIds.toList());
        }
      });
    } catch (error) {
      if (!mounted) return;
      _showError('Failed to add recipe: $error');
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade400,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(userCollectionsProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: collectionsAsync.when(
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => SizedBox(
          height: 200,
          child: Center(
            child: Text('Failed to load collections: $error'),
          ),
        ),
        data: (collections) {
          if (collections.isEmpty) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: Text('Create a collection first from Collections.'),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add to collections',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: collections.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    final isSelected =
                        _selectedCollectionIds.contains(collection.id);
                    final isFavoritesAndLiked =
                        collection.isDefault && widget.isRecipeLiked;

                    return _buildCollectionTile(
                      collection: collection,
                      isSelected: isSelected,
                      isFavoritesAndLiked: isFavoritesAndLiked,
                      onChanged: (value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedCollectionIds.add(collection.id);
                          } else {

                            if (!isFavoritesAndLiked) {
                              _selectedCollectionIds.remove(collection.id);
                            }
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isAdding ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.rosePink.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isAdding ? null : _addToSelectedCollections,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rosePink,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isAdding
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Add to ${_selectedCollectionIds.length} Collection${_selectedCollectionIds.length != 1 ? 's' : ''}',
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCollectionTile({
    required Collection collection,
    required bool isSelected,
    required bool isFavoritesAndLiked,
    required ValueChanged<bool?> onChanged,
  }) {
    final isFavorites = collection.isDefault;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.rosePink.withValues(alpha: 0.2),
        ),
        color: isSelected ? AppColors.rosePink.withValues(alpha: 0.1) : null,
      ),
      child: CheckboxListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        value: isSelected,
        onChanged: isFavoritesAndLiked ? null : onChanged,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          collection.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (isFavorites)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.rosePink.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Favorites',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.rosePink,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${collection.recipeCount} recipe${collection.recipeCount != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        activeColor: AppColors.rosePink,
        checkColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
