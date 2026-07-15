import 'package:bostra/models/campaign_filter.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/search/state/search_state.dart';
import 'package:bostra/ui/search/view_model/search_view_model.dart';
import 'package:bostra/ui/search/widgets/app_search_bar.dart';
import 'package:bostra/ui/search/widgets/circle_back_button.dart';
import 'package:bostra/ui/search/widgets/search_result_tile.dart';
import 'package:bostra/widgets/campaign_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Displays the results of a search as a scrollable list. The top bar mirrors
/// the search field (read-only) and taps back to the search screen for editing.
class SearchResultsScreen extends ConsumerStatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.query);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openFilter() async {
    final notifier = ref.read(searchViewModelProvider.notifier);
    final current = ref.read(searchViewModelProvider);
    final result = await showCampaignFilterSheet(
      context,
      current: current.filter,
      source: current.results,
    );
    if (result != null) notifier.setFilter(result);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Back button + read-only search field ──────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleBackButton(onTap: () => context.pop()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppSearchBar(
                      controller: _controller,
                      readOnly: true,
                      // Tapping the field returns to the editable search screen.
                      onTap: () => context.pop(),
                      onFilterTap: _openFilter,
                      filterActive: state.filter.isActive,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SearchState state) {
    switch (state.status) {
      case SearchStatus.initial:
      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case SearchStatus.error:
        return _CenteredMessage(
          icon: Icons.error_outline,
          title: 'Something went wrong',
          subtitle: state.errorMessage ?? 'Please try again.',
        );

      case SearchStatus.success:
        if (state.results.isEmpty) {
          return _CenteredMessage(
            icon: Icons.search_off,
            title: 'No results found',
            subtitle: 'Nothing matched “${state.query}”.',
          );
        }

        final results = state.filteredResults;
        if (results.isEmpty) {
          return _CenteredMessage(
            icon: Icons.filter_alt_off_outlined,
            title: 'No matches for your filters',
            subtitle: 'Try widening or clearing your filters.',
            action: TextButton(
              onPressed: () => ref
                  .read(searchViewModelProvider.notifier)
                  .setFilter(const CampaignFilter()),
              child: Text(
                'Clear filters',
                style: AppTextStyle.bodyText1.copyWith(
                  color: AppColors.textButtonColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                '${results.length} '
                '${results.length == 1 ? 'result' : 'results'} '
                'for “${state.query}”'
                '${state.filter.isActive ? ' · filtered' : ''}',
                style: AppTextStyle.bodyText2,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: results.length,
                itemBuilder: (context, index) =>
                    SearchResultTile(campaign: results[index]),
              ),
            ),
          ],
        );
    }
  }
}

class _CenteredMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const _CenteredMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.blackColor.withAlpha(90)),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyle.h3, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTextStyle.bodyText2,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 8),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
