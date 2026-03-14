import 'package:firebase_ai/firebase_ai.dart';

class GenerativeAiService {
  GenerativeAiService({
    FirebaseAI? firebaseAI,
    String model = 'gemini-2.0-flash',
    Content? systemInstruction,
    GenerationConfig? generationConfig,
    List<SafetySetting>? safetySettings,
  }) : _model = (firebaseAI ?? FirebaseAI.googleAI()).generativeModel(
         model: model,
         systemInstruction: systemInstruction,
         generationConfig: generationConfig,
         safetySettings: safetySettings,
       );

  final GenerativeModel _model;

  /// Generates a single text response from Gemini.
  Future<String> generateText({
    required String prompt,
    List<Content> context = const <Content>[],
  }) async {
    final normalizedPrompt = prompt.trim();
    if (normalizedPrompt.isEmpty) {
      throw const GenerativeAiException('Prompt cannot be empty.');
    }

    try {
      final response = await _model.generateContent(<Content>[
        ...context,
        Content.text(normalizedPrompt),
      ]);

      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        throw const GenerativeAiException(
          'Gemini returned an empty response.',
        );
      }

      return text;
    } on FirebaseAIException catch (e) {
      throw GenerativeAiException('Gemini request failed: ${e.message}');
    } catch (e) {
      throw GenerativeAiException('Unexpected Gemini error: $e');
    }
  }

  Stream<String> streamText({
    required String prompt,
    List<Content> context = const <Content>[],
  }) async* {
    final normalizedPrompt = prompt.trim();
    if (normalizedPrompt.isEmpty) {
      throw const GenerativeAiException('Prompt cannot be empty.');
    }

    try {
      final stream = _model.generateContentStream(<Content>[
        ...context,
        Content.text(normalizedPrompt),
      ]);

      await for (final response in stream) {
        final chunk = response.text;
        if (chunk != null && chunk.isNotEmpty) {
          yield chunk;
        }
      }
    } on FirebaseAIException catch (e) {
      throw GenerativeAiException('Gemini stream failed: ${e.message}');
    } catch (e) {
      throw GenerativeAiException('Unexpected Gemini stream error: $e');
    }
  }

  /// Generates nutrition information for an ingredient per 100g.
  /// Returns a JSON string that should be parsed into a NutritionInfo object.
  Future<IngredientNutritionData> generateNutritionFromAI(
    String ingredientName,
  ) async {
    final prompt = '''
For a food ingredient called "$ingredientName", estimate the nutritional values per 100g.
Return ONLY a valid JSON object with these exact keys (no markdown, no code blocks):
{
  "calories": <integer>,
  "carbohydrates": <decimal>,
  "protein": <decimal>,
  "fat": <decimal>,
  "fiber": <decimal>,
  "sugar": <decimal>,
  "sodium": <decimal>
}

Most common values for reference:
- Calories: typically 0-900 per 100g
- Carbohydrates, Protein, Fat: decimal numbers in grams
- Fiber: decimal number in grams
- Sugar: decimal number in grams
- Sodium: decimal number in mg
''';

    try {
      final jsonString = await generateText(prompt: prompt);
      return IngredientNutritionData.fromJson(jsonString);
    } catch (e) {
      throw GenerativeAiException(
        'Failed to generate nutrition data: $e',
      );
    }
  }

  /// Generates density (g/ml) for a liquid ingredient.
  Future<double> generateDensityFromAI(String ingredientName) async {
    final prompt = '''
For a liquid ingredient called "$ingredientName", estimate the density in g/ml at room temperature (20°C).
Return ONLY a single decimal number with no other text or formatting. For example: 1.03

Common density values for reference:
- Water: 1.0
- Oil: ~0.92
- Vinegar: ~1.01
- Milk: ~1.03
- Honey: ~1.42
- Alcohol: ~0.79
''';

    try {
      final densityString = await generateText(prompt: prompt);
      final density = double.tryParse(densityString.trim());
      if (density == null || density <= 0) {
        throw GenerativeAiException(
          'Invalid density value returned: $densityString',
        );
      }
      return density;
    } catch (e) {
      throw GenerativeAiException(
        'Failed to generate density data: $e',
      );
    }
  }

  /// Generates average piece weight (g) for a solid ingredient.
  /// Returns weight in grams for a typical piece/unit (e.g., 1 clove, 1 slice, 1 berry).
  Future<double> generateAveragePieceWeightFromAI(
    String ingredientName,
  ) async {
    final prompt = '''
For a solid ingredient called "$ingredientName", estimate the average weight in grams of ONE typical piece, unit, or serving portion.

Examples:
- "garlic clove" → ~3-4g per clove
- "egg (large)" → ~50g per egg
- "strawberry" → ~12g per berry
- "apple (medium)" → ~182g per apple
- "slice of bread" → ~28g per slice
- "tomato (medium)" → ~123g per tomato
- "onion (small)" → ~70g per onion
- "carrot (medium)" → ~61g per carrot

Return ONLY a single decimal number with no other text. For example: 12.5

Consider what a "typical" piece would be for this ingredient.
''';

    try {
      final weightString = await generateText(prompt: prompt);
      final weight = double.tryParse(weightString.trim());
      if (weight == null || weight <= 0) {
        throw GenerativeAiException(
          'Invalid weight value returned: $weightString',
        );
      }
      return weight;
    } catch (e) {
      throw GenerativeAiException(
        'Failed to generate average piece weight: $e',
      );
    }
  }
}

class GenerativeAiException implements Exception {
  const GenerativeAiException(this.message);

  final String message;

  @override
  String toString() => 'GenerativeAiException: $message';
}

/// Helper class for parsing nutrition data from Gemini AI.
class IngredientNutritionData {
  const IngredientNutritionData({
    required this.calories,
    required this.carbohydrates,
    required this.protein,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
  });

  final int calories;
  final double carbohydrates;
  final double protein;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;

  factory IngredientNutritionData.fromJson(String jsonString) {
    try {
      // Remove any markdown code blocks if present
      String cleaned = jsonString
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Parse the JSON
      final json = _parseJson(cleaned);

      return IngredientNutritionData(
        calories: _toInt(json['calories']),
        carbohydrates: _toDouble(json['carbohydrates']),
        protein: _toDouble(json['protein']),
        fat: _toDouble(json['fat']),
        fiber: _toDouble(json['fiber']),
        sugar: _toDouble(json['sugar']),
        sodium: _toDouble(json['sodium']),
      );
    } catch (e) {
      throw GenerativeAiException('Failed to parse nutrition data: $e');
    }
  }

  /// Simple JSON parser to avoid adding external dependencies
  static Map<String, dynamic> _parseJson(String jsonString) {
    final trimmed = jsonString.trim();
    if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) {
      throw FormatException('Invalid JSON format');
    }

    final content = trimmed.substring(1, trimmed.length - 1);
    final result = <String, dynamic>{};
    
    // Split by commas (simple approach - works for flat objects)
    final pairs = content.split(',');
    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        final key = parts[0].trim().replaceAll('"', '');
        final value = parts[1].trim();
        result[key] = value;
      }
    }

    return result;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? double.parse(value).round();
    }
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0.0;
  }
}
