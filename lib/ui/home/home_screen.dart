import 'package:bostra/constants/assets_path.dart';
import 'package:bostra/enums/chips_options.dart';
import 'package:bostra/models/campaign_filter.dart';
import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/home/widgets/home_card.dart';
import 'package:bostra/ui/home/widgets/home_chips.dart';
import 'package:bostra/ui/notifications/view_model/invitations_view_model.dart';
import 'package:bostra/ui/search/widgets/app_search_bar.dart';
import 'package:bostra/widgets/campaign_filter_sheet.dart';
import 'package:bostra/ui/start_campain/state/campaign_state.dart';
import 'package:bostra/ui/start_campain/view_model/get_campaign_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  CampaignFilter _filter = const CampaignFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilter(List<CampaignModel> source) async {
    final result = await showCampaignFilterSheet(
      context,
      current: _filter,
      source: source,
    );
    if (result != null && mounted) {
      setState(() => _filter = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(getCampaignViewModelProvider);

    // Wraps [child] in a single-item ListView so RefreshIndicator always has
    // a scrollable to attach to, and LayoutBuilder centres content vertically
    // in the exact remaining space below the fixed header.
    Widget centeredScrollable(Widget child) {
      return LayoutBuilder(
        builder: (_, constraints) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: Center(child: child),
            ),
          ],
        ),
      );
    }

    Widget body;
    switch (state.status) {
      case CampaignStatus.initial:
      case CampaignStatus.loading:
        body = centeredScrollable(const CircularProgressIndicator());

      case CampaignStatus.error:
        body = centeredScrollable(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              state.errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
            ),
          ),
        );

      case CampaignStatus.success:
        // Apply the active filter (industry + amount requested).
        final filteredCampaigns = _filter.apply(state.campaigns);

        if (filteredCampaigns.isEmpty) {
          body = centeredScrollable(
            Text(
              _filter.isActive
                  ? 'No campaigns match your filters.'
                  : 'No campaigns available right now.',
              textAlign: TextAlign.center,
            ),
          );
        } else {
          body = ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            itemCount: filteredCampaigns.length,
            itemBuilder: (context, index) =>
                HomeCard(campaign: filteredCampaigns[index]),
          );
        }
    }

    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(
          "${AssetsPath.svgPath}logo_without_slogan.svg",
          width: 88,
        ),
        centerTitle: false,
        actions: [
          _NotificationBell(
            count: ref.watch(pendingInvitationCountProvider).value ?? 0,
            onTap: () async {
              await context.push('/notifications');
              ref.invalidate(pendingInvitationCountProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Fixed header ──────────────────────────────────────────────
            const SizedBox(height: 12),
            // Tapping the bar opens the dedicated search screen; the field
            // animates up into place via a shared Hero.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: AppSearchBar(
                controller: _searchController,
                readOnly: true,
                onTap: () => context.push('/search'),
                onFilterTap: () => _openFilter(state.campaigns),
                filterActive: _filter.isActive,
              ),
            ),
            const SizedBox(height: 14),
            HomeChips(
              values: ChipsOptions.values,
              labelBuilder: (options) => options.text,
              iconBuilder: null,
              selectedValue: _filter.industry,
              onSelected: (category) {
                setState(() {
                  _filter = _filter.copyWith(industry: category);
                });
              },
            ),
            const SizedBox(height: 14),

            // ── Scrollable / state-driven content ─────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref
                    .read(getCampaignViewModelProvider.notifier)
                    .fetchVerifiedCampaigns(),
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashboard bell with an unread badge for pending founder invitations.
class _NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _NotificationBell({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(LucideIcons.bell),
        ),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: AppColors.redColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.whiteColor, width: 1.5),
              ),
              child: Text(
                count > 9 ? '9+' : '$count',
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyText3.copyWith(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
