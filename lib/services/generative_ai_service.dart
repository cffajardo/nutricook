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
}

class GenerativeAiException implements Exception {
  const GenerativeAiException(this.message);

  final String message;

  @override
  String toString() => 'GenerativeAiException: $message';
}
