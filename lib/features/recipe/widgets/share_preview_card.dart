import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A Spotify-style link preview card for sharing recipes
/// 
/// Displays an image on the left and recipe info on the right
/// with a small arrow icon indicating it's clickable
class SharePreviewCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String recipeId;
  final VoidCallback? onTap;
  final double height;
  final double width;
  final EdgeInsets padding;

  const SharePreviewCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.recipeId,
    this.onTap,
    this.height = 100,
    this.width = double.infinity,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image on the left
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                child: Container(
                  width: height,
                  height: height,
                  color: Colors.grey[200],
                  child: _buildImage(),
                ),
              ),
              // Title and subtitle on the right
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Arrow icon on the right
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the image widget with loading and error states
  Widget _buildImage() {
    if (imageUrl.isEmpty) {
      return Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey[400],
          size: 32,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.grey[400]!,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey[400],
          size: 32,
        ),
      ),
    );
  }
}
