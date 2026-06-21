import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A text widget that collapses to [maxLines] with a "Read More / Show Less" toggle.
class SdExpandableText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int maxLines;

  const SdExpandableText({
    super.key,
    required this.text,
    required this.style,
    this.maxLines = 3,
  });

  @override
  State<SdExpandableText> createState() => _SdExpandableTextState();
}

class _SdExpandableTextState extends State<SdExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: widget.style,
          maxLines: _expanded ? null : widget.maxLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Show Less' : 'Read More',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
