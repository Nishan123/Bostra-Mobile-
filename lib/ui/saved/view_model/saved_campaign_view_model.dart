import 'dart:convert';
import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/ui/saved/state/saved_campaign_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final savedCampaignViewModelProvider =
    NotifierProvider<SavedCampaignViewModel, SavedCampaignState>(
  SavedCampaignViewModel.new,
);

class SavedCampaignViewModel extends Notifier<SavedCampaignState> {
  static const _prefsKey = 'bostra_saved_campaigns';

  @override
  SavedCampaignState build() {
    // Load persisted saves after the first frame so build stays synchronous.
    Future.microtask(_loadFromPrefs);
    return const SavedCampaignState();
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Adds the campaign if not already saved; removes it if it is.
  /// Persists the new list to SharedPreferences immediately.
  void toggleSave(CampaignModel campaign) {
    if (campaign.id == null) return;

    final updated = state.savedIds.contains(campaign.id)
        ? state.savedCampaigns.where((c) => c.id != campaign.id).toList()
        : [...state.savedCampaigns, campaign];

    state = state.copyWith(savedCampaigns: updated);
    _persistToPrefs(updated);
  }

  bool isSaved(String? id) => id != null && state.savedIds.contains(id);

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw) as List<dynamic>;
      final campaigns = decoded
          .map((e) => CampaignModel.fromJson(e as Map<String, dynamic>))
          .toList();

      state = state.copyWith(savedCampaigns: campaigns);
    } catch (_) {
      // Corrupted prefs — silently start fresh.
    }
  }

  Future<void> _persistToPrefs(List<CampaignModel> campaigns) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        campaigns.map((c) => c.toJson()).toList(),
      );
      await prefs.setString(_prefsKey, encoded);
    } catch (_) {
      // Write failure is non-fatal; in-memory state is still correct.
    }
  }
}
