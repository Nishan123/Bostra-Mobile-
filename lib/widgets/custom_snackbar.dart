import 'dart:async';
import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class CustomSnackBar {
  static void _show(
    BuildContext context,
    IconData icon,
    Color bgColor,
    String text,
  ) {
    final overlay = Overlay.of(context);
    final safeTop = MediaQueryData.fromView(View.of(context)).padding.top;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: safeTop + 12,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: _SnackBarContent(
              icon: icon,
              bgColor: bgColor,
              text: text,
              onDismiss: () => entry.remove(),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
  }

  static void showSuccessSnackBar(BuildContext context, String text) {
    _show(context, LucideIcons.laugh, AppColors.primaryColor.withValues(alpha: 12), text);
  }

  static void showErrorSnackBar(BuildContext context, String text) {
    _show(context, LucideIcons.frown, AppColors.redColor.withValues(alpha:12), text);
  }

  static void showNormalSnackBar(BuildContext context, String text) {
    _show(context, LucideIcons.meh, AppColors.blueColor.withValues(alpha: 12), text);
  }
}

class _SnackBarContent extends StatefulWidget {
  final IconData icon;
  final Color bgColor;
  final String text;
  final VoidCallback onDismiss;

  const _SnackBarContent({
    required this.icon,
    required this.bgColor,
    required this.text,
    required this.onDismiss,
  });

  @override
  State<_SnackBarContent> createState() => _SnackBarContentState();
}

class _SnackBarContentState extends State<_SnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Timer _autoDismissTimer;
  bool _didDisposeController = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 250),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Auto dismiss
    _autoDismissTimer = Timer(const Duration(seconds: 5), _dismiss);
  }

  void _dismiss() async {
    if (!mounted || _didDisposeController) return;
    if (_controller.isAnimating) return;

    await _controller.reverse();
    if (mounted) {
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _didDisposeController = true;
    _autoDismissTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: GestureDetector(
          onTap: _dismiss,
          onVerticalDragUpdate: (details) {
            if (details.delta.dy < -8) {
              _dismiss();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: BorderRadius.circular(80),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(widget.icon, color: AppColors.whiteColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}