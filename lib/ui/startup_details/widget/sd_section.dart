import 'package:flutter/material.dart';

/// A padded container that wraps each content section of the details screen.
class SdSection extends StatelessWidget {
  final Widget child;
  const SdSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: child,
    );
  }
}
