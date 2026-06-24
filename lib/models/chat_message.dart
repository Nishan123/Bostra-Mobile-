enum ChatRole { user, assistant }

/// A single message in the portfolio chat.
class ChatMessage {
  final ChatRole role;
  final String text;
  final bool isError;

  const ChatMessage({
    required this.role,
    required this.text,
    this.isError = false,
  });

  /// Gemini expects roles 'user' or 'model'.
  String get apiRole => role == ChatRole.user ? 'user' : 'model';

  bool get isUser => role == ChatRole.user;
}
