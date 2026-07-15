import 'dart:convert';

import 'package:bostra/constants/table_names.dart';
import 'package:bostra/failure/failure.dart';
import 'package:bostra/models/campaign_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Dependency Injection definition at the top of the file
final searchControllerProvider = Provider((ref) {
  return SearchController();
});

/// Handles direct communication with data sources for the search feature:
///   • Supabase   → full-text-ish search over verified campaigns.
///   • SharedPrefs → persisted recent search terms ("Search Histories").
class SearchController {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Local-storage key for the recent search terms list.
  static const String _historyKey = 'bostra_search_history';

  /// Maximum number of recent terms to keep.
  static const int _historyLimit = 10;

  // ── Remote search ─────────────────────────────────────────────────────────

  /// Searches verified campaigns whose name, tagline, industry or description
  /// matches [query] (case-insensitive). Returns an empty list for a blank
  /// query rather than hitting the network.
  Future<Either<Failure, List<CampaignModel>>> searchCampaigns(
    String query,
  ) async {
    final term = query.trim();
    if (term.isEmpty) return const Right(<CampaignModel>[]);

    try {
      // Escape PostgREST wildcard characters so user input is treated literally.
      final safe = term.replaceAll('%', r'\%').replaceAll('_', r'\_');
      final pattern = '%$safe%';

      final response = await _supabase
          .from(TableNames.campaignTable)
          .select()
          .eq('is_verified', true)
          .or(
            'startup_name.ilike.$pattern,'
            'short_tagline.ilike.$pattern,'
            'industry.ilike.$pattern,'
            'description.ilike.$pattern',
          )
          .order('created_at', ascending: false);

      final campaigns = (response as List<dynamic>)
          .map((e) => CampaignModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(campaigns);
    } catch (e) {
      return Left(ApiFailure(message: "Failed to search campaigns: $e"));
    }
  }

  // ── Search history (local) ────────────────────────────────────────────────

  /// Returns the persisted recent search terms, most-recent first.
  Future<Either<Failure, List<String>>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey);
      if (raw == null || raw.isEmpty) return const Right(<String>[]);

      final decoded = jsonDecode(raw) as List<dynamic>;
      return Right(decoded.map((e) => e.toString()).toList());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: "Failed to load history: $e"));
    }
  }

  /// Adds [term] to the front of the history (de-duplicated, capped) and
  /// returns the updated list.
  Future<Either<Failure, List<String>>> addToHistory(String term) async {
    final value = term.trim();
    if (value.isEmpty) return getHistory();

    try {
      final current = await getHistory();
      final existing = current.getOrElse(() => <String>[]);

      final updated = <String>[
        value,
        ...existing.where((e) => e.toLowerCase() != value.toLowerCase()),
      ].take(_historyLimit).toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_historyKey, jsonEncode(updated));
      return Right(updated);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: "Failed to save history: $e"));
    }
  }

  /// Removes every persisted search term.
  Future<Either<Failure, Unit>> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      return const Right(unit);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: "Failed to clear history: $e"));
    }
  }
}
