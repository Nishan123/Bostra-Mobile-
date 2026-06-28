import 'package:bostra/controllers/investment_controller.dart';
import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/saved/view_model/saved_campaign_view_model.dart';
import 'package:bostra/ui/startup_details/widget/sd_backers_list.dart';
import 'package:bostra/ui/startup_details/widget/sd_circle_icon_button.dart';
import 'package:bostra/ui/startup_details/widget/sd_company_row.dart';
import 'package:bostra/ui/startup_details/widget/sd_cover_image.dart';
import 'package:bostra/ui/startup_details/widget/sd_fund_bar.dart';
import 'package:bostra/ui/startup_details/widget/sd_funding_header.dart';
import 'package:bostra/ui/startup_details/widget/sd_investment_details.dart';
import 'package:bostra/ui/startup_details/widget/sd_month_projection_card.dart';
import 'package:bostra/ui/startup_details/widget/sd_pitch_video_thumbnail.dart';
import 'package:bostra/ui/startup_details/widget/sd_section.dart';
import 'package:bostra/widgets/widget_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StartupDetailsScreen extends ConsumerWidget {
  final CampaignModel campaign;

  const StartupDetailsScreen({super.key, required this.campaign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = campaign;
    final isSaved = ref.watch(
      savedCampaignViewModelProvider.select((s) => s.savedIds.contains(c.id)),
    );
    final hasInvested =
        ref.watch(hasInvestedProvider(c.id ?? '')).valueOrNull ?? false;

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
                    // ── Title + funding ────────────────────────────────────
                    SdFundingHeader(campaign: c),

                    const _SectionDivider(),

                    // ── Company row ────────────────────────────────────────
                    SdCompanyRow(campaign: c),

                    const _SectionDivider(),

                    // ── Pitch video ────────────────────────────────────────
                    SdSection(
                      child: SdPitchVideoThumbnail(videoUrl: c.pitchVideoUrl),
                    ),

                    const SizedBox(height: 4),

                    // ── Description ────────────────────────────────────────
                    if (c.description.isNotEmpty) ...[
                      const WidgetTitle(text: 'Description',padding: EdgeInsets.only(bottom: 0,left: 16),),
                      SdSection(
                        child: Text(c.description,style: AppTextStyle.bodyText1,)
                      ),
                    ],

                    const SizedBox(height: 4),

                    // ── Backers till now (renders its own header) ──────────
                    SdBackersList(campaignId: c.id ?? ''),

                    const SizedBox(height: 4),

                    // ── Company Vision / Month Projections ─────────────────
                    if (c.monthProjections.isNotEmpty) ...[
                      const WidgetTitle(text: 'Company Vision'),
                      ...c.monthProjections.map(
                        (mp) => SdMonthProjectionCard(projection: mp),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // ── Investment details ─────────────────────────────────
                    if (c.minimumInvestment > 0 || c.equityOffered > 0) ...[
                      const WidgetTitle(text: 'Investment Details'),
                      SdInvestmentDetails(campaign: c),
                    ],

                    // Spacing so content isn't hidden behind the sticky button
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          // ── Sticky fund bar ──────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SdFundBar(
              campaign: c,
              hasInvested: hasInvested,
              onFund: () => context.pushNamed('fundStartup', extra: c),
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
