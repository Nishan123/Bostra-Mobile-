import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Loads the campaign's pitch video from its YouTube URL (the `pitch_video_url`
/// column). Extracts the video id, plays it inline with the package's built-in
/// controls + fullscreen, and falls back to a placeholder when the URL is
/// missing or isn't a recognisable YouTube link.
class SdPitchVideoThumbnail extends StatefulWidget {
  final String? videoUrl;
  const SdPitchVideoThumbnail({super.key, this.videoUrl});

  @override
  State<SdPitchVideoThumbnail> createState() => _SdPitchVideoThumbnailState();
}

class _SdPitchVideoThumbnailState extends State<SdPitchVideoThumbnail> {
  YoutubePlayerController? _controller;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = _idFromUrl(widget.videoUrl);
    if (_videoId != null) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: _videoId!,
        autoPlay: false,
      );
    }
  }

  @override
  void didUpdateWidget(covariant SdPitchVideoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl == widget.videoUrl) return;

    final newId = _idFromUrl(widget.videoUrl);
    if (newId == _videoId) return;
    _videoId = newId;

    if (newId == null) {
      _controller?.close();
      _controller = null;
      setState(() {});
    } else if (_controller == null) {
      setState(() {
        _controller = YoutubePlayerController.fromVideoId(
          videoId: newId,
          autoPlay: false,
        );
      });
    } else {
      // cue (not load) keeps it paused, matching autoPlay: false.
      _controller!.cueVideoById(videoId: newId);
    }
  }

  /// Pulls the 11-char video id out of any YouTube URL shape
  /// (watch?v=, youtu.be/, shorts/, embed/, music). Returns null if it isn't one.
  static String? _idFromUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    return YoutubePlayerController.convertUrlToId(url.trim());
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      final hasUrl =
          widget.videoUrl != null && widget.videoUrl!.trim().isNotEmpty;
      return _PitchVideoPlaceholder(hasUrl: hasUrl);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: YoutubePlayer(
        controller: controller,
        aspectRatio: 16 / 9,
      ),
    );
  }
}

/// Shown when there's no usable YouTube URL.
class _PitchVideoPlaceholder extends StatelessWidget {
  final bool hasUrl;
  const _PitchVideoPlaceholder({required this.hasUrl});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.videocam_off_rounded,
              color: Colors.white54,
              size: 34,
            ),
            const SizedBox(height: 8),
            Text(
              hasUrl ? "Couldn't load pitch video" : 'No pitch video available',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
