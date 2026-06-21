import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/saved/view_model/saved_campaign_view_model.dart';
import 'package:bostra/ui/startup_details/widget/sd_backers_list.dart';
import 'package:bostra/ui/startup_details/widget/sd_circle_icon_button.dart';
import 'package:bostra/ui/startup_details/widget/sd_cover_image.dart';
import 'package:bostra/ui/startup_details/widget/sd_detail_row.dart';
import 'package:bostra/ui/startup_details/widget/sd_expandable_text.dart';
import 'package:bostra/ui/startup_details/widget/sd_month_projection_card.dart';
import 'package:bostra/ui/startup_details/widget/sd_pitch_video_thumbnail.dart';
import 'package:bostra/ui/startup_details/widget/sd_section.dart';
import 'package:bostra/widgets/fund_progress_bar.dart';
import 'package:bostra/widgets/info_chip.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StartupDetailsScreen extends ConsumerWidget {
  final CampaignModel campaign;

  const StartupDetailsScreen({super.key, required this.campaign});

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = campaign;
    final isSaved = ref.watch(
      savedCampaignViewModelProvider
          .select((s) => s.savedIds.contains(c.id)),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Scrollable body ──────────────────────────────────────────────
          CustomScrollView(
            slivers: [
              // ── Collapsing cover image with gallery dots ─────────────────
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                leading: SdCircleIconButton(
                  icon: LucideIcons.arrow_left,
                  onTap: () => Navigator.of(context).pop(),
                ),
                actions: [
                  SdCircleIconButton(
                    icon: isSaved ? Icons.favorite : LucideIcons.heart,
                    iconColor: isSaved ? AppColors.redColor : null,
                    onTap: () => ref
                        .read(savedCampaignViewModelProvider.notifier)
                        .toggleSave(c),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: SdGalleryCover(
                    coverImageUrl: c.coverImageUrl,
                    galleryUrls: c.galleryImageUrls,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title + tagline + funding ──────────────────────────
                    SdSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Startup title
                          SdExpandableText(
                            text: c.startupName,
                            style: AppTextStyle.h1.copyWith(fontSize: 22),
                            maxLines: 2,
                          ),

                          const SizedBox(height: 14),

                          // Funding amounts row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Rs ${_fmt(c.currentFunding)} ',
                                      style: AppTextStyle.h4.copyWith(
                                        color: AppColors.blackColor,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'Raised of Rs ${_fmt(c.targetAmount)}',
                                      style: AppTextStyle.bodyText3.copyWith(
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (c.endDate != null)
                                InfoChip(
                                  text:
                                      '${c.endDate!.difference(DateTime.now()).inDays.clamp(0, 9999)} Days left',
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          FundProgressBar(value: c.fundingProgress),
                        ],
                      ),
                    ),

                    const _SectionDivider(),

                    // ── Company row ────────────────────────────────────────
                    SdSection(
                      child: Row(
                        children: [
                          // Logo / avatar
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.turnaryColor,
                            backgroundImage: c.logoUrl != null
                                ? NetworkImage(c.logoUrl!)
                                : null,
                            child: c.logoUrl == null
                                ? Text(
                                    c.startupName.isNotEmpty
                                        ? c.startupName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        c.startupName,
                                        style: AppTextStyle.h4,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    if (c.isVerified)
                                      Icon(
                                        LucideIcons.circle_check_big,
                                        color: AppColors.blueColor,
                                        size: 16,
                                      ),
                                  ],
                                ),
                                Text(
                                  c.isVerified
                                      ? 'Verified'
                                      : 'Pending verification',
                                  style: AppTextStyle.bodyText3,
                                ),
                              ],
                            ),
                          ),

                          Icon(LucideIcons.chevron_right,
                              color: AppColors.black10, size: 20),
                        ],
                      ),
                    ),

                    const _SectionDivider(),

                    // ── Pitch video ────────────────────────────────────────
                    SdSection(
                      child: SdPitchVideoThumbnail(videoUrl: c.pitchVideoUrl),
                    ),

                    const SizedBox(height: 4),

                    // ── Description ────────────────────────────────────────
                    if (c.description.isNotEmpty) ...[
                      _SectionHeader(title: 'Description'),
                      SdSection(
                        child: SdExpandableText(
                          text: c.description,
                          style: AppTextStyle.bodyText2.copyWith(
                            height: 1.6,
                            color: AppColors.blackColor.withAlpha(160),
                          ),
                          maxLines: 5,
                        ),
                      ),
                    ],

                    const SizedBox(height: 4),

                    // ── Backers till now ───────────────────────────────────
                    if (10 > 0) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Backers till now',
                                style: AppTextStyle.h4),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
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
                      SdBackersList(
                        count: 4,
                        currentFunding: c.currentFunding,
                      ),
                    ],

                    const SizedBox(height: 4),

                    // ── Company Vision / Month Projections ─────────────────
                    if (c.monthProjections.isNotEmpty) ...[
                      _SectionHeader(title: 'Company Vision'),
                      ...c.monthProjections.map(
                        (mp) => SdMonthProjectionCard(projection: mp),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // ── Investment details ─────────────────────────────────
                    if (c.minimumInvestment > 0 || c.equityOffered > 0) ...[
                      _SectionHeader(title: 'Investment Details'),
                      SdSection(
                        child: Column(
                          children: [
                            if (c.minimumInvestment > 0)
                              SdDetailRow(
                                label: 'Minimum Investment',
                                value: 'Rs ${_fmt(c.minimumInvestment)}',
                              ),
                            if (c.equityOffered > 0)
                              SdDetailRow(
                                label: 'Equity Offered',
                                value:
                                    '${c.equityOffered.toStringAsFixed(1)}%',
                              ),
                            SdDetailRow(
                              label: 'Target Amount',
                              value: 'Rs ${_fmt(c.targetAmount)}',
                            ),
                            if (c.industry.isNotEmpty)
                              SdDetailRow(
                                  label: 'Industry', value: c.industry),
                            if (c.founderName != null)
                              SdDetailRow(
                                  label: 'Founder',
                                  value: c.founderName!),
                          ],
                        ),
                      ),
                    ],

                    // Spacing so content isn't hidden behind the sticky button
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          // ── Sticky "Fund Now" button ─────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
                top: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppColors.blackColor.withAlpha(20),
                    width: 0.6,
                  ),
                ),
              ),
              child: PrimaryButton(
                text: 'Fund Now',
                onTap: () => context.pushNamed(
                  'fundStartup',
                  extra: c,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Private layout helpers ──────────────────────────────────────────────────

/// Thin full-width divider between major sections
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.6,
      indent: 16,
      endIndent: 16,
      color: AppColors.blackColor.withAlpha(25),
    );
  }
}

/// Bold section header, left-padded — "Description", "Company Vision", etc.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 14, bottom: 6, right: 16),
      child: Text(title, style: AppTextStyle.h4),
    );
  }
}
