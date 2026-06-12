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
  final TableNames _tables = TableNames();

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
          .from(_tables.campaignTable)
          .insert(campaignData)
          .select()
          .single();
      return Right(CampaignModel.fromJson(response));
    } catch (e) {
      return Left(ApiFailure(message: "Failed to start campaign: $e"));
    }
  }
}