import 'package:flutter/material.dart';
import 'package:nutricook/core/theme/app_theme.dart';
import 'package:nutricook/models/recipe/recipe.dart';

class RecipeActionsModal extends StatelessWidget {
  final Recipe recipe;
  final bool isOwner;
  final VoidCallback onStartCooking;
  final VoidCallback onAddToPlanner;
  final VoidCallback onAddToCollection;
  final VoidCallback onEditCopy;
  final VoidCallback onDelete;
  final VoidCallback onReport;
  final VoidCallback onShare;

  const RecipeActionsModal({
    super.key,
    required this.recipe,
    required this.onStartCooking,
    required this.onAddToPlanner,
    required this.onAddToCollection,
    required this.onEditCopy,
    required this.onDelete,
    required this.onReport,
    required this.onShare,
    this.isOwner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _buildActionTile(
            context,
            icon: Icons.play_circle_outline_rounded,
            label: 'Start Cooking',
            onTap: onStartCooking,
          ),
          _buildActionTile(
            context,
            icon: Icons.calendar_today_outlined,
            label: 'Add to Planner',
            onTap: onAddToPlanner,
          ),
          _buildActionTile(
            context,
            icon: Icons.collections_bookmark_outlined,
            label: 'Add to Collection',
            onTap: onAddToCollection,
          ),
          _buildActionTile(
            context,
            icon: Icons.copy_rounded,
            label: 'Edit Recipe (Creates Copy, keeps servings)',
            onTap: onEditCopy,
          ),
          _buildActionTile(
            context,
            icon: Icons.share_rounded,
            label: 'Share Recipe',
            onTap: onShare,
          ),

          if (isOwner)
            _buildActionTile(
              context,
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: Colors.redAccent,
              onTap: onDelete,
            ),

          _buildActionTile(
            context,
            icon: Icons.report_gmailerrorred_rounded,
            label: 'Report Recipe',
            color: Colors.black38,
            onTap: onReport,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.rosePink,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: color == AppColors.rosePink ? Colors.black87 : color,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: color.withValues(alpha: 0.3),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
