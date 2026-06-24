import 'package:bostra/constants/assets_path.dart';
import 'package:bostra/enums/chips_options.dart';
import 'package:bostra/ui/home/widgets/home_card.dart';
import 'package:bostra/ui/home/widgets/home_chips.dart';
import 'package:bostra/ui/home/widgets/home_search_bar.dart';
import 'package:bostra/ui/start_campain/state/campaign_state.dart';
import 'package:bostra/ui/start_campain/view_model/get_campaign_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ChipsOptions _selectedCategory = ChipsOptions.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        var filteredCampaigns = state.campaigns;

        // Filter by category chip
        if (_selectedCategory != ChipsOptions.all) {
          filteredCampaigns = filteredCampaigns.where((campaign) =>
              campaign.industry.trim().toLowerCase() ==
              _selectedCategory.text.trim().toLowerCase()).toList();
        }

        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          filteredCampaigns = filteredCampaigns.where((campaign) =>
              campaign.startupName.toLowerCase().contains(query) ||
              campaign.shortTagline.toLowerCase().contains(query)).toList();
        }

        if (filteredCampaigns.isEmpty) {
          body = centeredScrollable(
            const Text(
              'No campaigns available right now.',
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
          IconButton(onPressed: () {}, icon: const Icon(LucideIcons.bell)),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Fixed header ──────────────────────────────────────────────
            const SizedBox(height: 12),
            HomeSearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onFilterTap: () {},
            ),
            const SizedBox(height: 14),
            HomeChips(
              values: ChipsOptions.values,
              labelBuilder: (options) => options.text,
              iconBuilder: null,
              selectedValue: _selectedCategory,
              onSelected: (category) {
                setState(() {
                  _selectedCategory = category;
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
