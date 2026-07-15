import 'package:bostra/controllers/campaign_controller.dart';
import 'package:bostra/controllers/reward_controller.dart';
import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/models/reward_tier_model.dart';
import 'package:bostra/ui/start_campain/state/campaign_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final campaignViewModelProvider = NotifierProvider<StartCampaignViewModel, CampaignState>(StartCampaignViewModel.new);

class StartCampaignViewModel extends Notifier<CampaignState> {
  late CampaignController _campaignController;
  late RewardController _rewardController;

  @override
  CampaignState build() {
    _campaignController = ref.read(campaignControllerProvider);
    _rewardController = ref.read(rewardControllerProvider);
    return const CampaignState();
  }

  /// Begins a fresh campaign draft scoped to [companyId]. Every campaign is
  /// launched under a company, so the id is seeded here and preserved through
  /// all four steps via copyWith.
  void startForCompany(String companyId) {
    state = CampaignState(
      campaign: CampaignModel(companyId: companyId),
    );
  }

  void updateStartupName(String name) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(startupName: name),
    );
  }

  void updateShortTagline(String tagline) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(shortTagline: tagline),
    );
  }

  void updateIndustry(String industry) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(industry: industry),
    );
  }

  void updateCoverImageUrl(String? url) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(coverImageUrl: url),
    );
  }

  /// Stores up to 4 local image paths. Index 0 is the primary cover — it is
  /// also written to [coverImageUrl] so the rest of the app always has a
  /// single cover reference without duplicating uploads.
  void updateCoverImages(List<String> paths) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(
        galleryImageUrls: paths,
        coverImageUrl: paths.isNotEmpty ? paths.first : null,
      ),
    );
  }

  void updateMonthProjection(
    int monthNumber,
    String monthLabel, {
    String? objectives,
    String? goals,
    String? initiative,
  }) {
    final list = List<MonthProjection>.from(state.campaign.monthProjections);
    final index = list.indexWhere((element) => element.monthNumber == monthNumber);

    final currentProj = index != -1
        ? list[index]
        : MonthProjection(monthNumber: monthNumber, monthLabel: monthLabel);

    final updatedProj = currentProj.copyWith(
      objectives: objectives,
      goals: goals,
      initiative: initiative,
    );

    if (index != -1) {
      list[index] = updatedProj;
    } else {
      list.add(updatedProj);
    }

    state = state.copyWith(
      campaign: state.campaign.copyWith(monthProjections: list),
    );
  }

  void updateDescription(String description) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(description: description),
    );
  }

  void updateProblemStatement(String problem) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(problemStatement: problem),
    );
  }

  void updateSolution(String solution) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(solution: solution),
    );
  }

  void updateTargetAudience(String targetAudience) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(targetAudience: targetAudience),
    );
  }

  void updateUniqueSellingPoint(String usp) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(uniqueSellingPoint: usp),
    );
  }

  void updateDocumentUrl(String docType, String? url) {
    if (docType == 'Company Registration') {
      state = state.copyWith(
        campaign: state.campaign.copyWith(companyRegistrationUrl: url),
      );
    } else if (docType == 'PAN') {
      state = state.copyWith(
        campaign: state.campaign.copyWith(panUrl: url),
      );
    } else if (docType == 'MOA / AOA') {
      state = state.copyWith(
        campaign: state.campaign.copyWith(moaAoaUrl: url),
      );
    }
  }

  void updateTargetAmount(double amount) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(targetAmount: amount),
    );
  }

  /// Funding due date (deadline). Stored at the end of the chosen day so the
  /// campaign stays fundable through the whole due date.
  void updateEndDate(DateTime date) {
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    state = state.copyWith(
      campaign: state.campaign.copyWith(endDate: endOfDay),
    );
  }

  void updateAgreedToTerms(bool agreed) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(agreedToTerms: agreed),
    );
  }

  // ── Investor reward tiers ───────────────────────────────────────────────────

  void addRewardTier(RewardTierModel tier) {
    state = state.copyWith(rewardTiers: [...state.rewardTiers, tier]);
  }

  void updateRewardTier(int index, RewardTierModel tier) {
    if (index < 0 || index >= state.rewardTiers.length) return;
    final list = [...state.rewardTiers];
    list[index] = tier;
    state = state.copyWith(rewardTiers: list);
  }

  void removeRewardTier(int index) {
    if (index < 0 || index >= state.rewardTiers.length) return;
    final list = [...state.rewardTiers]..removeAt(index);
    state = state.copyWith(rewardTiers: list);
  }

  /// Reorders a tier from [oldIndex] to [newIndex] (ReorderableListView semantics).
  void reorderRewardTiers(int oldIndex, int newIndex) {
    final list = [...state.rewardTiers];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);
    state = state.copyWith(rewardTiers: list);
  }

  Future<bool> submitCampaign() async {
    state = state.copyWith(status: CampaignStatus.loading, errorMessage: null);

    try {
      var campaign = state.campaign;

      // 1. Upload company registration
      if (campaign.companyRegistrationUrl != null &&
          campaign.companyRegistrationUrl!.isNotEmpty &&
          _isLocalFile(campaign.companyRegistrationUrl!)) {
        final publicUrl = await _campaignController.uploadCampaignFile(
          filePath: campaign.companyRegistrationUrl!,
          folderName: 'documents',
        );
        campaign = campaign.copyWith(companyRegistrationUrl: publicUrl);
      }

      // 2. Upload PAN
      if (campaign.panUrl != null &&
          campaign.panUrl!.isNotEmpty &&
          _isLocalFile(campaign.panUrl!)) {
        final publicUrl = await _campaignController.uploadCampaignFile(
          filePath: campaign.panUrl!,
          folderName: 'documents',
        );
        campaign = campaign.copyWith(panUrl: publicUrl);
      }

      // 3. Upload MOA / AOA
      if (campaign.moaAoaUrl != null &&
          campaign.moaAoaUrl!.isNotEmpty &&
          _isLocalFile(campaign.moaAoaUrl!)) {
        final publicUrl = await _campaignController.uploadCampaignFile(
          filePath: campaign.moaAoaUrl!,
          folderName: 'documents',
        );
        campaign = campaign.copyWith(moaAoaUrl: publicUrl);
      }

      // 4. Upload Logo
      if (campaign.logoUrl != null &&
          campaign.logoUrl!.isNotEmpty &&
          _isLocalFile(campaign.logoUrl!)) {
        final publicUrl = await _campaignController.uploadCampaignFile(
          filePath: campaign.logoUrl!,
          folderName: 'media',
        );
        campaign = campaign.copyWith(logoUrl: publicUrl);
      }

      // 5. Upload Pitch Video
      if (campaign.pitchVideoUrl != null &&
          campaign.pitchVideoUrl!.isNotEmpty &&
          _isLocalFile(campaign.pitchVideoUrl!)) {
        final publicUrl = await _campaignController.uploadCampaignFile(
          filePath: campaign.pitchVideoUrl!,
          folderName: 'media',
        );
        campaign = campaign.copyWith(pitchVideoUrl: publicUrl);
      }

      // 6. Upload Gallery / Cover Images
      // coverImageUrl is always derived from galleryImageUrls[0] so we upload
      // everything in one pass and avoid uploading the same file twice.
      if (campaign.galleryImageUrls.isNotEmpty) {
        final List<String> uploadedUrls = [];
        for (final localPath in campaign.galleryImageUrls) {
          if (localPath.isNotEmpty && _isLocalFile(localPath)) {
            final publicUrl = await _campaignController.uploadCampaignFile(
              filePath: localPath,
              folderName: 'media',
            );
            uploadedUrls.add(publicUrl);
          } else {
            uploadedUrls.add(localPath);
          }
        }
        campaign = campaign.copyWith(
          galleryImageUrls: uploadedUrls,
          // Keep coverImageUrl in sync with the primary gallery image.
          coverImageUrl: uploadedUrls.first,
        );
      } else if (campaign.coverImageUrl != null &&
          campaign.coverImageUrl!.isNotEmpty &&
          _isLocalFile(campaign.coverImageUrl!)) {
        // Fallback: single cover image set via the old path.
        final publicUrl = await _campaignController.uploadCampaignFile(
          filePath: campaign.coverImageUrl!,
          folderName: 'media',
        );
        campaign = campaign.copyWith(coverImageUrl: publicUrl);
      }

      final result = await _campaignController.createCampaign(campaign);

      return await result.fold(
        (failure) async {
          state = state.copyWith(
            status: CampaignStatus.error,
            errorMessage: failure.errorMessage,
          );
          return false;
        },
        (savedCampaign) async {
          final campaignId = savedCampaign.id;
          if (campaignId == null || campaignId.isEmpty) {
            state = state.copyWith(
              status: CampaignStatus.error,
              errorMessage: 'Campaign was created without an id.',
            );
            return false;
          }

          // Persist investor reward tiers into their own table (upload any
          // local tier images first). Snapshots for investors are created
          // automatically at investment time by a DB trigger.
          final tiers = await _uploadTierImages(state.rewardTiers);
          final tierResult =
              await _rewardController.createTiersForCampaign(campaignId, tiers);

          return tierResult.fold(
            (failure) {
              state = state.copyWith(
                status: CampaignStatus.error,
                errorMessage:
                    'Campaign saved, but rewards failed: ${failure.errorMessage}',
              );
              return false;
            },
            (_) {
              state = state.copyWith(
                status: CampaignStatus.success,
                campaign: savedCampaign,
              );
              return true;
            },
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: CampaignStatus.error,
        errorMessage: "Failed to upload media files: $e",
      );
      return false;
    }
  }

  /// Uploads any locally-picked tier images and swaps in their public URLs.
  Future<List<RewardTierModel>> _uploadTierImages(
    List<RewardTierModel> tiers,
  ) async {
    final result = <RewardTierModel>[];
    for (final tier in tiers) {
      if (tier.imageUrl != null &&
          tier.imageUrl!.isNotEmpty &&
          _isLocalFile(tier.imageUrl!)) {
        final url = await _campaignController.uploadCampaignFile(
          filePath: tier.imageUrl!,
          folderName: 'rewards',
        );
        result.add(tier.copyWith(imageUrl: url));
      } else {
        result.add(tier);
      }
    }
    return result;
  }

  bool _isLocalFile(String path) {
    return !path.startsWith('http://') && !path.startsWith('https://');
  }

  void resetStatus() {
    state = state.copyWith(status: CampaignStatus.initial, errorMessage: null);
  }
}
