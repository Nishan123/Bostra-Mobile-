import 'dart:io';
import 'package:bostra/constants/table_names.dart';
import 'package:bostra/failure/failure.dart';
import 'package:bostra/models/campaign_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final campaignControllerProvider = Provider((ref){
  return CampaignController();
});

class CampaignController {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Either<Failure, CampaignModel>> createCampaign(
    CampaignModel newCampaign,
  ) async {
    try {
      // Set the logged-in user's ID if not already set
      final userId = _supabase.auth.currentUser?.id;
      final campaignData = newCampaign.copyWith(userId: userId).toJson();
      
      // Remove frontend-only validation fields not present in DB
      campaignData.remove('agreed_to_terms');

      // Remove auto-generated fields that database will set if they are null
      if (campaignData['id'] == null) {
        campaignData.remove('id');
      }
      if (campaignData['created_at'] == null) {
        campaignData.remove('created_at');
      }
      if (campaignData['updated_at'] == null) {
        campaignData.remove('updated_at');
      }
      final response = await _supabase
          .from(TableNames.campaignTable)
          .insert(campaignData)
          .select()
          .single();
      return Right(CampaignModel.fromJson(response));
    } catch (e) {
      if (e.toString().contains('must be verified')) {
        return const Left(ApiFailure(
          message:
              'This company must be verified before you can launch a campaign.',
        ));
      }
      return Left(ApiFailure(message: "Failed to start campaign: $e"));
    }
  }



  Future<String> uploadCampaignFile({
    required String filePath,
    required String folderName,
  }) async {
    final file = File(filePath);
    final fileName = filePath.split('/').last;
    final userId = _supabase.auth.currentUser?.id ?? 'anonymous';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Unique path in bucket, e.g. "userId/documents/17822992_registration.pdf"
    final storagePath = '$userId/$folderName/${timestamp}_$fileName';
    
    await _supabase.storage.from('campaigns').upload(
          storagePath,
          file,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );
        
    return _supabase.storage.from('campaigns').getPublicUrl(storagePath);
  }

  // Get all the verified public campaign
  Future<Either<Failure, List<CampaignModel>>> getVerifiedCampaigns() async {
    try {
      final response = await _supabase
          .from(TableNames.campaignTable)
          .select()
          .eq('is_verified', true)
          .order('created_at', ascending: false);
      final campaigns = (response as List<dynamic>)
          .map((e) => CampaignModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(campaigns);
    } catch (e) {
      return Left(ApiFailure(message: "Failed to fetch campaigns: $e"));
    }
  }

  // Get campaigns created by the current user
  Future<Either<Failure, List<CampaignModel>>> getMyCampaigns() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return const Right([]);
      
      final response = await _supabase
          .from(TableNames.campaignTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      final campaigns = (response as List<dynamic>)
          .map((e) => CampaignModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(campaigns);
    } catch (e) {
      return Left(ApiFailure(message: "Failed to fetch user campaigns: $e"));
    }
  }

  // Get all campaigns launched under a given company.
  Future<Either<Failure, List<CampaignModel>>> getCampaignsByCompany(
    String companyId,
  ) async {
    try {
      final response = await _supabase
          .from(TableNames.campaignTable)
          .select()
          .eq('company_id', companyId)
          .order('created_at', ascending: false);
      final campaigns = (response as List<dynamic>)
          .map((e) => CampaignModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(campaigns);
    } catch (e) {
      return Left(ApiFailure(message: "Failed to fetch company campaigns: $e"));
    }
  }

  /// Founder management action: update a campaign's target amount and/or
  /// funding end date. Only the provided fields are written. Authorization is
  /// enforced by the `campaign_update_founders` RLS policy (creator, owner, or
  /// any active founder of the campaign's company).
  Future<Either<Failure, CampaignModel>> updateCampaignFunding({
    required String campaignId,
    double? targetAmount,
    DateTime? endDate,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (targetAmount != null) updates['target_amount'] = targetAmount;
      if (endDate != null) updates['end_date'] = endDate.toIso8601String();

      if (updates.isEmpty) {
        return const Left(GeneralFailure('Nothing to update.'));
      }

      final response = await _supabase
          .from(TableNames.campaignTable)
          .update(updates)
          .eq('id', campaignId)
          .select()
          .single();
      return Right(CampaignModel.fromJson(response));
    } catch (e) {
      return Left(ApiFailure(message: "Failed to update campaign: $e"));
    }
  }
}