import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Service for handling recipe sharing with image capture and deep linking
class RecipeShareService {
  static const String _deepLinkScheme = 'nutricook';
  static const String _deepLinkPath = 'recipe';

  /// Generates the deep link URL for a recipe
  /// Example: nutricook://recipe/recipe-id-123
  static String generateDeepLink(String recipeId) {
    return '$_deepLinkScheme://$_deepLinkPath/$recipeId';
  }

  /// Captures a widget to an image
  /// 
  /// [globalKey] - The GlobalKey of the widget to capture
  /// [pixelRatio] - Optional pixel ratio for image quality (default: 2.0)
  /// 
  /// Returns the image as Uint8List or null if capture fails
  static Future<Uint8List?> captureWidgetToImage(
    GlobalKey globalKey, {
    double pixelRatio = 2.0,
  }) async {
    try {
      debugPrint('[RecipeShareService] Starting widget capture...');

      final RenderRepaintBoundary boundary =
          globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        debugPrint('[RecipeShareService] Failed to convert image to bytes');
        return null;
      }

      debugPrint('[RecipeShareService] Widget captured successfully');
      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint('[RecipeShareService] Error capturing widget: $e');
      return null;
    }
  }

  /// Saves image bytes to a temporary file
  /// 
  /// [imageBytes] - The image data
  /// [filename] - Optional filename (default: recipe_preview.png)
  /// 
  /// Returns the file path or null if save fails
  static Future<String?> saveImageToTemp(
    Uint8List imageBytes, {
    String filename = 'recipe_preview.png',
  }) async {
    try {
      debugPrint('[RecipeShareService] Saving image to temporary directory...');

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');
      await file.writeAsBytes(imageBytes);

      debugPrint('[RecipeShareService] Image saved to ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('[RecipeShareService] Error saving image: $e');
      return null;
    }
  }

  /// Shares a recipe using the SharePreviewCard
  /// 
  /// [context] - BuildContext for error handling
  /// [globalKey] - GlobalKey of the SharePreviewCard widget
  /// [recipeId] - Recipe ID for deep link
  /// [recipeName] - Recipe name for share text
  /// [shareText] - Optional custom share text (includes deep link by default)
  /// 
  /// Returns true if sharing was initiated successfully
  static Future<bool> shareRecipe(
    BuildContext context, {
    required GlobalKey globalKey,
    required String recipeId,
    required String recipeName,
    String? shareText,
  }) async {
    try {
      debugPrint('[RecipeShareService] Starting recipe share process...');

      // Capture the card as an image
      final imageBytes = await captureWidgetToImage(globalKey);
      if (imageBytes == null) {
        _showErrorSnackBar(context, 'Failed to capture recipe card image');
        return false;
      }

      // Save image to temporary directory
      final imagePath = await saveImageToTemp(imageBytes);
      if (imagePath == null) {
        _showErrorSnackBar(context, 'Failed to save recipe card image');
        return false;
      }

      // Generate deep link
      final deepLink = generateDeepLink(recipeId);

      // Prepare share text
      final finalShareText = shareText ??
          'Check out this recipe: $recipeName\n\n$deepLink';

      debugPrint('[RecipeShareService] Deep link: $deepLink');
      debugPrint('[RecipeShareService] Share text: $finalShareText');

      // Share using share_plus
      final result = await Share.shareXFiles(
        [XFile(imagePath)],
        text: finalShareText,
      );

      debugPrint('[RecipeShareService] Share result: ${result.status}');

      if (result.status == ShareResultStatus.success) {
        _showSuccessSnackBar(context, 'Recipe shared!');
        return true;
      } else if (result.status == ShareResultStatus.dismissed) {
        debugPrint('[RecipeShareService] Share was dismissed by user');
        return false;
      }

      return false;
    } catch (e) {
      debugPrint('[RecipeShareService] Error sharing recipe: $e');
      _showErrorSnackBar(context, 'Error sharing recipe');
      return false;
    }
  }

  /// Alternative: Upload image to Firebase Storage and share the link
  /// Useful if you want cloud-hosted preview images
  /// 
  /// [imageBytes] - The image data
  /// [recipeId] - Recipe ID for storage path
  /// [userId] - User ID for storage path
  /// 
  /// Returns the Firebase Storage URL or null if upload fails
  static Future<String?> uploadImageToFirebase(
    Uint8List imageBytes, {
    required String recipeId,
    required String userId,
  }) async {
    try {
      debugPrint('[RecipeShareService] Uploading image to Firebase Storage...');

      final storage = FirebaseStorage.instance;
      final fileName =
          'recipe_previews/$userId/$recipeId/preview_${DateTime.now().millisecondsSinceEpoch}.png';

      final ref = storage.ref().child(fileName);
      final uploadTask = ref.putData(imageBytes);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('[RecipeShareService] Image uploaded to: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('[RecipeShareService] Error uploading to Firebase: $e');
      return null;
    }
  }

  /// Generates a shareable deep link with optional UTM parameters for analytics
  static String generateDeepLinkWithUTM({
    required String recipeId,
    String? source,
    String? medium,
    String? campaign,
  }) {
    final deepLink = generateDeepLink(recipeId);

    if (source == null && medium == null && campaign == null) {
      return deepLink;
    }

    final params = <String, String>{};
    if (source != null) params['utm_source'] = source;
    if (medium != null) params['utm_medium'] = medium;
    if (campaign != null) params['utm_campaign'] = campaign;

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$deepLink?$queryString';
  }

  /// Helper method to show error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Helper method to show success snackbar
  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
