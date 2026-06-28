import 'package:bostra/controllers/investment_controller.dart';
import 'package:bostra/models/backer_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/widgets/widget_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Real "Backers till now" section. Maps the campaign's investors (from the
/// `investments` ledger, joined to `users`) to name + profile pic + amount via
/// [campaignBackersProvider]. Renders nothing until there's at least one backer.
class SdBackersList extends ConsumerWidget {
  final String campaignId;
  final int visibleCount;

  const SdBackersList({
    super.key,
    required this.campaignId,
    this.visibleCount = 3,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (campaignId.isEmpty) return const SizedBox.shrink();

    final backersAsync = ref.watch(campaignBackersProvider(campaignId));

    return backersAsync.when(
      loading: () => _section(
        child: Column(
          children: List.generate(visibleCount, (_) => const _SkeletonTile()),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (backers) {
        if (backers.isEmpty) return const SizedBox.shrink();
        final display = backers.length > visibleCount
            ? visibleCount
            : backers.length;

        return _section(
          child: Column(
            children: [
              ...List.generate(display, (i) => _BackerTile(backer: backers[i])),
              if (backers.length > visibleCount) ...[
                const SizedBox(height: 2),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'See All',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// "Backers till now | See All" header + the supplied body.
  Widget _section({required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WidgetTitle(
                text: "Backers till now",
                padding: EdgeInsets.only(left: 0, bottom: 4),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        child,
        const SizedBox(height: 4),
      ],
    );
  }
}

class _BackerTile extends StatelessWidget {
  final BackerModel backer;
  const _BackerTile({required this.backer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 0.6, color: AppColors.black10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: EdgeInsets.only(left: 14, right: 14, bottom: 8),
      child: Row(
        children: [
          // Avatar — real profile pic, silhouette fallback.
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.turnaryColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.blackColor.withAlpha(15),
                width: 0.8,
              ),
            ),
            child: ClipOval(
              child: backer.hasProfilePic
                  ? Image.network(
                      backer.profilePicUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _silhouette(),
                    )
                  : _silhouette(),
            ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              backer.displayName,
              style: AppTextStyle.bodyText1.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Amount chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Rs ${backer.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: AppColors.whiteColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _silhouette() => Center(
    child: Icon(
      LucideIcons.user,
      size: 18,
      color: AppColors.black10.withAlpha(100),
    ),
  );
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    final base = AppColors.blackColor.withAlpha(12);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: base, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(width: 40),
          Container(
            width: 70,
            height: 24,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}
