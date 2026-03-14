import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Handles deep link parsing and routing for shared recipes
/// 
/// Deep link format: https://nutricook.app/recipe/<recipeId>
/// or: nutricook://recipe/<recipeId>
class DeepLinkHandler {
  static const String _deepLinkDomain = 'nutricook.app';
  static const String _deepLinkHost = 'nutricook.app';
  static const String _appScheme = 'nutricook';
  static const String _recipePath = 'recipe';

  /// Parses a deep link and extracts the recipe ID
  /// 
  /// Handles both:
  /// - https://nutricook.app/recipe/recipe-id-123
  /// - nutricook://recipe/recipe-id-123
  static String? parseRecipeId(Uri deepLink) {
    debugPrint('[DeepLinkHandler] Parsing deep link: $deepLink');

    try {
      // Check for https URL scheme
      if (deepLink.scheme == 'https' &&
          (deepLink.host == _deepLinkHost || deepLink.host == _deepLinkDomain)) {
        final segments = deepLink.pathSegments;
        if (segments.length >= 2 && segments[0] == _recipePath) {
          final recipeId = segments[1];
          debugPrint('[DeepLinkHandler] Extracted recipe ID: $recipeId');
          return recipeId;
        }
      }

      // Check for custom scheme
      if (deepLink.scheme == _appScheme) {
        final path = deepLink.path;
        if (path.startsWith('/$_recipePath/')) {
          final recipeId = path.replaceFirst('/$_recipePath/', '');
          debugPrint('[DeepLinkHandler] Extracted recipe ID from app scheme: $recipeId');
          return recipeId;
        }
      }
    } catch (e) {
      debugPrint('[DeepLinkHandler] Error parsing deep link: $e');
    }

    return null;
  }

  /// Handles navigation to a shared recipe
  /// 
  /// Returns true if the deep link was successfully handled
  static Future<bool> handleDeepLink(
    GoRouter router,
    Uri deepLink, {
    required Function(String recipeId) onRecipeIdExtracted,
  }) async {
    debugPrint('[DeepLinkHandler] Handling deep link: $deepLink');

    final recipeId = parseRecipeId(deepLink);
    if (recipeId == null) {
      debugPrint('[DeepLinkHandler] Could not extract recipe ID from deep link');
      return false;
    }

    // Call the callback to fetch and navigate to the recipe
    onRecipeIdExtracted(recipeId);
    return true;
  }

  /// Validates if a deep link is for a recipe
  static bool isRecipeDeepLink(Uri deepLink) {
    if (deepLink.scheme == 'https' &&
        (deepLink.host == _deepLinkHost || deepLink.host == _deepLinkDomain)) {
      return deepLink.pathSegments.isNotEmpty &&
          deepLink.pathSegments[0] == _recipePath;
    }

    if (deepLink.scheme == _appScheme) {
      return deepLink.path.startsWith('/$_recipePath/');
    }

    return false;
  }
}
