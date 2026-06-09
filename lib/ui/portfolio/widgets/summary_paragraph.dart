import 'package:flutter/material.dart';

class SummaryParagraph extends StatelessWidget {
  final String text;
  const SummaryParagraph({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(text),
    );
  }
}
