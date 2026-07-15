import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/search/view_model/search_view_model.dart';
import 'package:bostra/ui/search/widgets/app_search_bar.dart';
import 'package:bostra/ui/search/widgets/circle_back_button.dart';
import 'package:bostra/ui/search/widgets/history_chip.dart';
import 'package:bostra/widgets/campaign_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Search entry screen: an autofocused search field (keyboard up) plus the
/// user's "Search Histories" chips and a "Clear History" action.
///
/// Reached by tapping the home search bar; the bar animates up into the top
/// slot via a shared [Hero]. Submitting a term pushes the results screen.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String term) async {
    final query = term.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();
    final success =
        await ref.read(searchViewModelProvider.notifier).search(query);
    if (!mounted) return;

    if (success) {
      context.pushNamed('searchResults', extra: query);
    } else {
      final message =
          ref.read(searchViewModelProvider).errorMessage ?? 'Search failed.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _onChipTap(String term) {
    _controller.text = term;
    _runSearch(term);
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
    final history =
        ref.watch(searchViewModelProvider.select((s) => s.history));
    final filterActive =
        ref.watch(searchViewModelProvider.select((s) => s.filter.isActive));

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Back button + search field ─────────────────────────────────
              Row(
                children: [
                  CircleBackButton(onTap: () => context.pop()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppSearchBar(
                      controller: _controller,
                      autofocus: true,
                      onSubmitted: _runSearch,
                      onFilterTap: _openFilter,
                      filterActive: filterActive,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Search Histories ───────────────────────────────────────────
              Text(
                'Search Histories',
                style: AppTextStyle.h1.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 18),

              if (history.isEmpty)
                Text(
                  'No recent searches yet.',
                  style: AppTextStyle.bodyText2,
                )
              else ...[
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final term in history)
                      HistoryChip(
                        label: term,
                        onTap: () => _onChipTap(term),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: () =>
                      ref.read(searchViewModelProvider.notifier).clearHistory(),
                  child: Text(
                    'Clear History',
                    style: AppTextStyle.bodyText1.copyWith(
                      color: AppColors.textButtonColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
