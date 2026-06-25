import 'package:bostra/constants/table_names.dart';
import 'package:bostra/failure/failure.dart';
import 'package:bostra/models/backer_model.dart';
import 'package:bostra/models/investment_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final investmentControllerProvider = Provider((ref) {
  return InvestmentController();
});

class InvestmentController {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Inserts a new investment row AND atomically updates the campaign's
  /// `current_funding` and `total_investors` via a Postgres RPC function.
  ///
  /// Returns the created [InvestmentModel] on success or a [Failure] on error.
  Future<Either<Failure, InvestmentModel>> invest({
    required String campaignId,
    required double amount,
  }) async {
    try {
      final investorId = _supabase.auth.currentUser?.id;
      if (investorId == null) {
        return Left(ApiFailure(message: 'Not authenticated'));
      }

      // 1. Call DB function that inserts investment + updates campaign atomically
      await _supabase.rpc('invest_in_campaign', params: {
        'p_campaign_id': campaignId,
        'p_investor_id': investorId,
        'p_amount': amount,
      });

      // 2. Fetch back the inserted row
      final response = await _supabase
          .from(TableNames.investmentsTable)
          .select()
          .eq('campaign_id', campaignId)
          .eq('investor_id', investorId)
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      return Right(InvestmentModel.fromJson(response));
    } catch (e) {
      return Left(ApiFailure(message: 'Investment failed: $e'));
    }
  }

  /// Fetches all investments made by the currently logged-in user.
  Future<Either<Failure, List<InvestmentModel>>> getMyInvestments() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return Right([]);

      final response = await _supabase
          .from(TableNames.investmentsTable)
          .select('*, campaign(*)')
          .eq('investor_id', userId)
          .order('created_at', ascending: false);

      final list = (response as List<dynamic>)
          .map((e) => InvestmentModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to fetch investments: $e'));
    }
  }

  /// Fetches the backers of a campaign (name, profile pic, total invested),
  /// via the `get_campaign_backers` RPC. The RPC runs SECURITY DEFINER so it
  /// can read other users' profiles regardless of RLS, exposing only safe
  /// fields. Ordered by amount, highest first.
  Future<Either<Failure, List<BackerModel>>> getCampaignBackers(
    String campaignId,
  ) async {
    try {
      final response = await _supabase.rpc(
        'get_campaign_backers',
        params: {'p_campaign_id': campaignId},
      );

      final list = (response as List<dynamic>)
          .map((e) => BackerModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to fetch backers: $e'));
    }
  }

  /// Whether the signed-in user has already backed [campaignId] — i.e. their
  /// uid is in the campaign's investors list. Checked against the investments
  /// ledger (the source of truth for that list) so it never goes stale.
  Future<Either<Failure, bool>> hasUserInvested(String campaignId) async {
    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) return const Right(false);

      final response = await _supabase
          .from(TableNames.investmentsTable)
          .select('id')
          .eq('campaign_id', campaignId)
          .eq('investor_id', uid)
          .limit(1)
          .maybeSingle();

      return Right(response != null);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to check funding status: $e'));
    }
  }
}

/// Async list of a campaign's backers, keyed by campaign id.
final campaignBackersProvider =
    FutureProvider.family<List<BackerModel>, String>((ref, campaignId) async {
  if (campaignId.isEmpty) return const [];
  final controller = ref.watch(investmentControllerProvider);
  final result = await controller.getCampaignBackers(campaignId);
  return result.fold(
    (failure) => throw Exception(failure.errorMessage),
    (backers) => backers,
  );
});

/// True when the signed-in user has already backed [campaignId]. Drives the
/// one-time-fund UX: "Fund Now" for new backers, "Add More Funding" for
/// existing ones. Defaults to false on error so funding is never wrongly blocked.
final hasInvestedProvider =
    FutureProvider.family<bool, String>((ref, campaignId) async {
  if (campaignId.isEmpty) return false;
  final controller = ref.watch(investmentControllerProvider);
  final result = await controller.hasUserInvested(campaignId);
  return result.fold((_) => false, (invested) => invested);
});
