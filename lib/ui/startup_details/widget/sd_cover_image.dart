import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Displays the campaign cover image (and optional gallery) in a PageView
/// with dot indicators at the bottom — matching the design screenshot.
class SdGalleryCover extends StatefulWidget {
  final String? coverImageUrl;
  final List<String> galleryUrls;

  const SdGalleryCover({
    super.key,
    this.coverImageUrl,
    this.galleryUrls = const [],
  });

  @override
  State<SdGalleryCover> createState() => _SdGalleryCoverState();
}

class _SdGalleryCoverState extends State<SdGalleryCover> {
  int _current = 0;

  List<String> get _images {
    final list = <String>[];
    if (widget.coverImageUrl != null) list.add(widget.coverImageUrl!);
    list.addAll(widget.galleryUrls);
    return list.isEmpty ? [] : list;
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;

    if (images.isEmpty) {
      return Container(
        color: AppColors.turnaryColor,
        child: Center(
          child: Icon(Icons.image_outlined, size: 64, color: Colors.grey.shade400),
        ),
      );
    }

    return Stack(
      children: [
        // ── Image PageView ─────────────────────────────────────────────────
        PageView.builder(
          itemCount: images.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) => Image.network(
            images[i],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, e, s) => Container(
              color: AppColors.turnaryColor,
              child: Icon(Icons.broken_image_outlined,
                  size: 48, color: Colors.grey.shade400),
            ),
          ),
        ),

        // ── Dot indicators ─────────────────────────────────────────────────
        if (images.length > 1)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _current ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _current
                        ? Colors.white
                        : Colors.white.withAlpha(130),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
