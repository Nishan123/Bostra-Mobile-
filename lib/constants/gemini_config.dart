import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Gemini configuration. The API key is read at runtime from the `.env` file
/// at the project root (copy `.env.example` → `.env` to get started).
///
///   GEMINI_API_KEY=your_key_here   ← get one at https://aistudio.google.com/apikey
///
/// NOTE: a key bundled in the app — even via `.env` — can still be extracted
/// from the binary. For production, proxy the call through a backend so the
/// key never ships to the client.
class GeminiConfig {
  /// Read from `.env`. Empty when the file is missing, unloaded, or unset —
  /// the try/catch guards against dotenv not being initialised.
  static String get apiKey {
    try {
      return dotenv.maybeGet('GEMINI_API_KEY')?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Model used for summaries. gemini-2.5-flash is fast and low-cost.
  static const String model = 'gemini-2.5-flash';

  /// True once a real key has been added to `.env`.
  static bool get isConfigured =>
      apiKey.isNotEmpty && apiKey != 'YOUR_GEMINI_API_KEY';
}
