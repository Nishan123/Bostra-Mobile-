import 'package:bostra/controllers/search_controller.dart';
import 'package:bostra/models/campaign_filter.dart';
import 'package:bostra/ui/search/state/search_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. NotifierProvider defined at the top of the file
final searchViewModelProvider =
    NotifierProvider<SearchViewModel, SearchState>(SearchViewModel.new);

class SearchViewModel extends Notifier<SearchState> {
  late final SearchController _searchController;

  @override
  SearchState build() {
    // 2. Read dependencies inside build() via ref.read
    _searchController = ref.read(searchControllerProvider);
    // Load persisted history after the first frame so build stays synchronous.
    Future.microtask(loadHistory);
    return const SearchState();
  }

  // ── Search history ─────────────────────────────────────────────────────────

  Future<void> loadHistory() async {
    final result = await _searchController.getHistory();
    result.fold(
      (_) {}, // Non-fatal: leave history empty on failure.
      (history) => state = state.copyWith(history: history),
    );
  }

  Future<void> clearHistory() async {
    final result = await _searchController.clearHistory();
    result.fold(
      (_) {},
      (_) => state = state.copyWith(history: const []),
    );
  }

  // ── Filtering ───────────────────────────────────────────────────────────────

  /// Applies [filter] to the current results (in-memory; no re-fetch).
  void setFilter(CampaignFilter filter) {
    state = state.copyWith(filter: filter);
  }

  // ── Search ──────────────────────────────────────────────────────────────────

  /// Runs a search for [query]. Persists the term to history, updates state and
  /// returns `true` when the request succeeded (so the View can navigate to the
  /// results screen).
  Future<bool> search(String query) async {
    final term = query.trim();
    if (term.isEmpty) return false;

    state = state.copyWith(
      status: SearchStatus.loading,
      query: term,
      errorMessage: null,
    );

    // Record the term first so it shows up under "Search Histories".
    final historyResult = await _searchController.addToHistory(term);
    historyResult.fold(
      (_) {},
      (history) => state = state.copyWith(history: history),
    );

    // 3. Fold the Either result to update the state accordingly
    final result = await _searchController.searchCampaigns(term);
    return result.fold(
      (failure) {
        state = state.copyWith(
          status: SearchStatus.error,
          errorMessage: failure.errorMessage,
        );
        return false;
      },
      (campaigns) {
        state = state.copyWith(
          status: SearchStatus.success,
          results: campaigns,
        );
        return true;
      },
    );
  }
}
