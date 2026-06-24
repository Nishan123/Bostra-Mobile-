import 'package:bostra/models/chat_message.dart';

enum ChatStatus { idle, sending }

class PortfolioChatState {
  final List<ChatMessage> messages;
  final ChatStatus status;

  const PortfolioChatState({
    this.messages = const [],
    this.status = ChatStatus.idle,
  });

  bool get isSending => status == ChatStatus.sending;

  PortfolioChatState copyWith({
    List<ChatMessage>? messages,
    ChatStatus? status,
  }) {
    return PortfolioChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
    );
  }
}
