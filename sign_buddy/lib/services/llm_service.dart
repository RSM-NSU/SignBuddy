import "package:flutter/foundation.dart";
import "package:google_generative_ai/google_generative_ai.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";

class LlmService {
  GenerativeModel? _model;

  GenerativeModel _getModel() {
    if (_model == null) {
      final apiKey = dotenv.env['GEMINI_API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY not found in ..env');
      }

      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
            'You are a post-processor for a sign language translator. '
                'You receive raw translation output which may contain:\n'
                '- Fingerspelled letters separated by spaces (e.g. "A X E L") that form words or names\n'
                '- Words strung together without punctuation\n'
                'Your job: reconstruct words from letters, add punctuation, fix capitalization, '
                'and produce a clean readable sentence. '
                'Preserve proper names. Reply with ONLY the final sentence, nothing else.'
        ),
      );
    }
    return _model!;
  }

  Future<String> processTranslation(String rawOutput) async {
    try {
      debugPrint('🤖 LLM called with: $rawOutput');

      final response = await _getModel().generateContent([
        Content.text(rawOutput),
      ]);

      debugPrint('✅ LLM response: ${response.text}');
      return response.text?.trim() ?? rawOutput;
    } catch (e) {
      debugPrint('❌ LLM error with: $e');
      return rawOutput;
    }
  }
}