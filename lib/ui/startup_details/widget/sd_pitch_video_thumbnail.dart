import 'package:bostra/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A 16:9 pitch video thumbnail with a play button overlay.
/// Tapping it would launch the video player (wired separately).
class SdPitchVideoThumbnail extends StatelessWidget {
  final String? videoUrl;
  const SdPitchVideoThumbnail({super.key, this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(color: const Color(0xFF1A1A2E)),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.redColor.withAlpha(230),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            Positioned(
              bottom: 10,
              left: 12,
              child: Text(
                videoUrl != null ? 'Pitch Video' : 'No pitch video available',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
