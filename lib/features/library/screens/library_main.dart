import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/features/library/library_constants.dart';

class LibraryMainScreen extends StatelessWidget {
  const LibraryMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 22,
          ),
        ),
        title: const Text(
          'Library',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: kLibraryCategories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 32,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final category = kLibraryCategories[index];
          return _buildCategoryCard(context, category: category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required LibraryCategoryDef category,
  }) {
    return GestureDetector(
      onTap: () {
        context.push('/library/${category.id}');
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardRose.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.rosePink.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(category.icon, size: 48, color: AppColors.rosePink),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            category.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
