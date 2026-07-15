import 'package:bostra/constants/table_names.dart';
import 'package:bostra/enums/reward_status.dart';
import 'package:bostra/failure/failure.dart';
import 'package:bostra/models/investment_reward_model.dart';
import 'package:bostra/models/reward_tier_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final rewardControllerProvider = Provider((ref) {
  return RewardController();
});

/// Data-source layer for the investment rewards feature: reward tiers
/// (campaign_reward_tiers) and earned reward snapshots (investment_rewards).
class RewardController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ── Reward tiers ────────────────────────────────────────────────────────────

  /// All reward tiers for a campaign, ordered by threshold (sort_order).
  Future<Either<Failure, List<RewardTierModel>>> getTiersForCampaign(
    String campaignId,
  ) async {
    if (campaignId.isEmpty) return const Right(<RewardTierModel>[]);
    try {
      final response = await _supabase
          .from(TableNames.campaignRewardTiersTable)
          .select()
          .eq('campaign_id', campaignId)
          .order('sort_order', ascending: true);

      final tiers = (response as List<dynamic>)
          .map((e) => RewardTierModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(tiers);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to load reward tiers: $e'));
    }
  }

  /// Bulk-inserts the reward tiers for a freshly created campaign. Tier order
  /// follows list order (index → sort_order).
  Future<Either<Failure, Unit>> createTiersForCampaign(
    String campaignId,
    List<RewardTierModel> tiers,
  ) async {
    if (tiers.isEmpty) return const Right(unit);
    try {
      final rows = <Map<String, dynamic>>[
        for (var i = 0; i < tiers.length; i++)
          tiers[i].toInsertJson(campaignId: campaignId, sortOrder: i),
      ];
      await _supabase.from(TableNames.campaignRewardTiersTable).insert(rows);
      return const Right(unit);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to save reward tiers: $e'));
    }
  }

  // ── Earned rewards (snapshots) ──────────────────────────────────────────────

  /// Earned reward snapshots for a single investment.
  Future<Either<Failure, List<InvestmentRewardModel>>> getRewardsForInvestment(
    String investmentId,
  ) async {
    if (investmentId.isEmpty) return const Right(<InvestmentRewardModel>[]);
    try {
      final response = await _supabase
          .from(TableNames.investmentRewardsTable)
          .select()
          .eq('investment_id', investmentId)
          .order('min_percent', ascending: true);

      final rewards = (response as List<dynamic>)
          .map((e) => InvestmentRewardModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(rewards);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to load earned rewards: $e'));
    }
  }

  /// The signed-in user's earned rewards for a given campaign (across all their
  /// investments in it). Used on the details screen to highlight what they've
  /// already unlocked.
  Future<Either<Failure, List<InvestmentRewardModel>>> getMyRewardsForCampaign(
    String campaignId,
  ) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null || campaignId.isEmpty) {
      return const Right(<InvestmentRewardModel>[]);
    }
    try {
      final response = await _supabase
          .from(TableNames.investmentRewardsTable)
          .select()
          .eq('campaign_id', campaignId)
          .eq('investor_id', uid)
          .order('min_percent', ascending: true);

      final rewards = (response as List<dynamic>)
          .map((e) => InvestmentRewardModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(rewards);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to load your rewards: $e'));
    }
  }

  /// Updates the fulfillment status of an earned reward. Used by founders
  /// (mark delivered) and investors (mark claimed). RLS enforces who may write.
  Future<Either<Failure, Unit>> updateRewardStatus({
    required String rewardId,
    required RewardStatus status,
  }) async {
    try {
      await _supabase
          .from(TableNames.investmentRewardsTable)
          .update({'status': status.toJson()})
          .eq('id', rewardId);
      return const Right(unit);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to update reward status: $e'));
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Reward tiers for a campaign, keyed by campaign id. Used on the details and
/// fund screens.
final rewardTiersProvider =
    FutureProvider.family<List<RewardTierModel>, String>((ref, campaignId) async {
  if (campaignId.isEmpty) return const [];
  final controller = ref.watch(rewardControllerProvider);
  final result = await controller.getTiersForCampaign(campaignId);
  return result.fold((f) => throw Exception(f.errorMessage), (tiers) => tiers);
});

/// Earned reward snapshots for a single investment, keyed by investment id.
final investmentRewardsProvider =
    FutureProvider.family<List<InvestmentRewardModel>, String>(
        (ref, investmentId) async {
  if (investmentId.isEmpty) return const [];
  final controller = ref.watch(rewardControllerProvider);
  final result = await controller.getRewardsForInvestment(investmentId);
  return result.fold((f) => throw Exception(f.errorMessage), (r) => r);
});

/// The signed-in user's earned rewards for a campaign, keyed by campaign id.
final myCampaignRewardsProvider =
    FutureProvider.family<List<InvestmentRewardModel>, String>(
        (ref, campaignId) async {
  if (campaignId.isEmpty) return const [];
  final controller = ref.watch(rewardControllerProvider);
  final result = await controller.getMyRewardsForCampaign(campaignId);
  return result.fold((f) => throw Exception(f.errorMessage), (r) => r);
});
