import 'package:bostra/models/chat_message.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/portfolio/state/portfolio_chat_state.dart';
import 'package:bostra/ui/portfolio/view_model/portfolio_chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Near-fullscreen chat sheet for asking questions about the current
/// portfolio. Scope is enforced server-side by the system instruction in
/// [PortfolioChatViewModel] — this widget is just the surface.
class PortfolioChatSheet extends ConsumerStatefulWidget {
  const PortfolioChatSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const PortfolioChatSheet(),
    );
  }

  @override
  ConsumerState<PortfolioChatSheet> createState() => _PortfolioChatSheetState();
}

class _PortfolioChatSheetState extends ConsumerState<PortfolioChatSheet> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    _inputController.clear();
    ref.read(portfolioChatViewModelProvider.notifier).send(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(portfolioChatViewModelProvider);

    // Keep the view pinned to the newest message.
    ref.listen<PortfolioChatState>(
      portfolioChatViewModelProvider,
      (_, __) => _scrollToBottom(),
    );

    final sheetHeight = MediaQuery.of(context).size.height * 0.9;
    final itemCount = state.messages.length + (state.isSending ? 1 : 0);

    return SizedBox(
      height: sheetHeight,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            _Header(
              onClose: () => Navigator.of(context).pop(),
              onReset: () =>
                  ref.read(portfolioChatViewModelProvider.notifier).reset(),
            ),
            Divider(height: 1, color: AppColors.blackColor.withAlpha(20)),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                itemCount: itemCount,
                itemBuilder: (context, i) {
                  if (i >= state.messages.length) {
                    return const _TypingBubble();
                  }
                  return _MessageBubble(message: state.messages[i]);
                },
              ),
            ),
            _InputBar(
              controller: _inputController,
              sending: state.isSending,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onReset;
  const _Header({required this.onClose, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withAlpha(22),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, size: 18, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Portfolio Assistant', style: AppTextStyle.h4),
                Text(
                  'Answers only about your portfolio',
                  style: AppTextStyle.bodyText3,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'New chat',
            onPressed: onReset,
            icon: Icon(Icons.refresh_rounded,
                color: AppColors.blackColor.withAlpha(140)),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            icon: Icon(Icons.close, color: AppColors.blackColor.withAlpha(140)),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    final Color bg;
    final Color fg;
    if (isUser) {
      bg = AppColors.primaryColor;
      fg = AppColors.whiteColor;
    } else if (message.isError) {
      bg = const Color(0xFFFFF1F0);
      fg = const Color(0xFFB42318);
    } else {
      bg = AppColors.blackColor.withAlpha(10);
      fg = AppColors.blackColor;
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: AppTextStyle.bodyText1.copyWith(color: fg, height: 1.35),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.blackColor.withAlpha(10),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        14,
        8,
        14,
        MediaQuery.of(context).padding.bottom > 0 ? 8 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.blackColor.withAlpha(20)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Ask about your portfolio…',
                hintStyle: AppTextStyle.bodyText1.copyWith(
                  color: AppColors.blackColor.withAlpha(90),
                ),
                filled: true,
                fillColor: AppColors.blackColor.withAlpha(8),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: sending ? null : onSend,
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: sending
                    ? AppColors.primaryColor.withAlpha(120)
                    : AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: AppColors.whiteColor,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
