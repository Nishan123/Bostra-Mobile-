import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';

class AvatarsWithCount extends StatelessWidget {
  final List<String> imageUrls;
  final int totalBackers;
  final double avatarSize;
  final double overlap = 18;
  final TextStyle? countTextStyle;
  const AvatarsWithCount({
    super.key,
    required this.imageUrls,
    required this.totalBackers,
    required this.avatarSize,
    this.countTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final visibleAvatars = imageUrls.take(3).toList();
    final stackWidth =
        avatarSize + (visibleAvatars.length - 1) * (avatarSize - overlap);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: stackWidth,
          height: avatarSize,
          child: Stack(
            children: List.generate(visibleAvatars.length, (i) {
              return Positioned(
                left: i * (avatarSize - overlap),
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      visibleAvatars[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color.fromARGB(255, 121, 94, 94),
                        child: const Icon(
                          Icons.person,
                          color: Color.fromARGB(255, 109, 109, 109),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 6),
        Text('+$totalBackers Backers', style: countTextStyle??AppTextStyle.h3),
      ],
    );
  }
}
