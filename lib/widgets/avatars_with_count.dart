import 'package:bostra/controllers/user_controller.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AvatarsWithCount extends ConsumerWidget {
  final List<String> investorIds;
  final int totalBackers;
  final double avatarSize;
  final double overlap = 18;
  final TextStyle? countTextStyle;
  const AvatarsWithCount({
    super.key,
    required this.investorIds,
    required this.totalBackers,
    required this.avatarSize,
    this.countTextStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (totalBackers == 0) {
      return Text('No backers', style: countTextStyle ?? AppTextStyle.h3);
    }

    final visibleCount = totalBackers > 3 ? 3 : totalBackers;
    final targetIds = investorIds.take(3).toList();

    // Watch the investor profiles provider
    final investorsAsync = ref.watch(campaignInvestorsProvider(targetIds));

    final labelText = totalBackers > 3
        ? '+$totalBackers Backers'
        : '$totalBackers Backer${totalBackers > 1 ? 's' : ''}';

    final stackWidth =
        avatarSize + (visibleCount - 1) * (avatarSize - overlap);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: stackWidth,
          height: avatarSize,
          child: investorsAsync.when(
            data: (users) {
              final userMap = {for (var u in users) u.id: u.profilePicUrl};
              final imageUrls = targetIds.map((id) => userMap[id] ?? "").toList();

              // Make sure we have exactly `visibleCount` slots to draw (filled with silhouettes if we don't have enough URLs mapped yet)
              while (imageUrls.length < visibleCount) {
                imageUrls.add("");
              }

              return Stack(
                children: List.generate(visibleCount, (i) {
                  final url = imageUrls[i];
                  final hasValidUrl = url.startsWith('http');

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
                        child: hasValidUrl
                            ? Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: const Color.fromARGB(255, 230, 235, 245),
                                  child: const Icon(
                                    Icons.person,
                                    color: Color.fromARGB(255, 100, 115, 145),
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color.fromARGB(255, 230, 235, 245),
                                child: const Icon(
                                  Icons.person,
                                  color: Color.fromARGB(255, 100, 115, 145),
                                ),
                              ),
                      ),
                    ),
                  );
                }).reversed.toList(),
              );
            },
            loading: () => _buildSilhouettes(visibleCount),
            error: (err, stack) => _buildSilhouettes(visibleCount),
          ),
        ),
        const SizedBox(width: 6),
        Text(labelText, style: countTextStyle ?? AppTextStyle.h3),
      ],
    );
  }

  Widget _buildSilhouettes(int count) {
    return Stack(
      children: List.generate(count, (i) {
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
              child: Container(
                color: const Color.fromARGB(255, 230, 235, 245),
                child: const Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 100, 115, 145),
                ),
              ),
            ),
          ),
        );
      }).reversed.toList(),
    );
  }
}
