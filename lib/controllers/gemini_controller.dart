import 'dart:convert';
import 'package:bostra/constants/gemini_config.dart';
import 'package:bostra/failure/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final geminiControllerProvider = Provider((ref) {
  return GeminiController();
});

/// Thin client over the Gemini REST API (`v1beta/...:generateContent`).
/// The API key is read from [GeminiConfig]; auth is sent via the
/// `x-goog-api-key` header so it stays out of the URL/logs.
class GeminiController {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  Future<Either<Failure, String>> generateText(String prompt) async {
    if (!GeminiConfig.isConfigured) {
      return Left(GeneralFailure(
        'Add your Gemini API key in lib/constants/gemini_config.dart '
        'to enable AI summaries.',
      ));
    }

    try {
      final uri = Uri.parse('$_baseUrl/${GeminiConfig.model}:generateContent');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': GeminiConfig.apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 800,
          },
        }),
      );

      if (response.statusCode != 200) {
        return Left(ApiFailure(
          statusCode: response.statusCode,
          message: _extractError(response.body) ??
              'Gemini request failed (${response.statusCode}).',
        ));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text = _extractText(data);
      if (text == null || text.trim().isEmpty) {
        return Left(GeneralFailure('Gemini returned an empty response.'));
      }
      return Right(text.trim());
    } catch (e) {
      return Left(GeneralFailure('Could not reach Gemini: $e'));
    }
  }

  /// Multi-turn chat. [systemInstruction] sets the persona + guardrails;
  /// [turns] is the ordered conversation, each `{'role': 'user'|'model',
  /// 'text': ...}`. Must start with a user turn.
  Future<Either<Failure, String>> chat({
    required String systemInstruction,
    required List<Map<String, String>> turns,
  }) async {
    if (!GeminiConfig.isConfigured) {
      return Left(GeneralFailure(
        'Add your Gemini API key in the .env file to use the assistant.',
      ));
    }
    if (turns.isEmpty) {
      return Left(GeneralFailure('Nothing to send.'));
    }

    try {
      final uri = Uri.parse('$_baseUrl/${GeminiConfig.model}:generateContent');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': GeminiConfig.apiKey,
        },
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {'text': systemInstruction},
            ],
          },
          'contents': [
            for (final turn in turns)
              {
                'role': turn['role'],
                'parts': [
                  {'text': turn['text'] ?? ''},
                ],
              },
          ],
          // Low temperature keeps answers grounded in the supplied portfolio.
          'generationConfig': {
            'temperature': 0.4,
            'maxOutputTokens': 800,
          },
        }),
      );

      if (response.statusCode != 200) {
        return Left(ApiFailure(
          statusCode: response.statusCode,
          message: _extractError(response.body) ??
              'Gemini request failed (${response.statusCode}).',
        ));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final text = _extractText(data);
      if (text == null || text.trim().isEmpty) {
        return Left(GeneralFailure('Gemini returned an empty response.'));
      }
      return Right(text.trim());
    } catch (e) {
      return Left(GeneralFailure('Could not reach Gemini: $e'));
    }
  }

  String? _extractText(Map<String, dynamic> data) {
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return null;

    final content =
        (candidates.first as Map<String, dynamic>)['content']
            as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) return null;

    return (parts.first as Map<String, dynamic>)['text'] as String?;
  }

  String? _extractError(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final error = data['error'] as Map<String, dynamic>?;
      return error?['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}
