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
}