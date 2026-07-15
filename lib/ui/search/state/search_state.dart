import 'package:bostra/models/campaign_filter.dart';
import 'package:bostra/models/campaign_model.dart';

enum SearchStatus { initial, loading, success, error }

class SearchState {
  /// Lifecycle status of the most recent search request.
  final SearchStatus status;

  /// Human-readable error when [status] is [SearchStatus.error].
  final String? errorMessage;

  /// The query that produced [results].
  final String query;

  /// Campaigns returned by the last search (unfiltered).
  final List<CampaignModel> results;

  /// Recent search terms, most-recent first ("Search Histories").
  final List<String> history;

  /// Active refinement applied on top of [results].
  final CampaignFilter filter;

  const SearchState({
    this.status = SearchStatus.initial,
    this.errorMessage,
    this.query = '',
    this.results = const [],
    this.history = const [],
    this.filter = const CampaignFilter(),
  });

  /// [results] with the active [filter] applied.
  List<CampaignModel> get filteredResults => filter.apply(results);

  SearchState copyWith({
    SearchStatus? status,
    String? errorMessage,
    String? query,
    List<CampaignModel>? results,
    List<String>? history,
    CampaignFilter? filter,
  }) {
    return SearchState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      query: query ?? this.query,
      results: results ?? this.results,
      history: history ?? this.history,
      filter: filter ?? this.filter,
    );
  }
}
