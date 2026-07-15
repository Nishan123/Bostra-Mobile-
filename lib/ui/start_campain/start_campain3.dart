import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/start_campain/widgets/campain_app_bar.dart';
import 'package:bostra/ui/start_campain/widgets/doc_upload_box.dart';
import 'package:bostra/ui/start_campain/widgets/start_campain_progress.dart';
import 'package:bostra/ui/start_campain/view_model/start_campaign_view_model.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StartCampain3 extends ConsumerWidget {
  const StartCampain3({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaign = ref.watch(campaignViewModelProvider).campaign;
    final notifier = ref.read(campaignViewModelProvider.notifier);

    return Scaffold(
      appBar: CampainAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress indicator
                    const StartCampainProgress(
                      currentStep: 3,
                      totalSteps: 5,
                    ),

                    const SizedBox(height: 16),

                    // Security notice
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Your documents will be encrypted & secure.',
                        style: AppTextStyle.h4.copyWith(
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Company Registration upload
                    DocUploadBox(
                      docType: 'Company Registration',
                      initialFilePath: campaign.companyRegistrationUrl,
                      onFilePicked: (file) {
                        notifier.updateDocumentUrl('Company Registration', file?.path);
                      },
                    ),
                    const SizedBox(height: 16),

                    // PAN upload
                    DocUploadBox(
                      docType: 'PAN',
                      initialFilePath: campaign.panUrl,
                      onFilePicked: (file) {
                        notifier.updateDocumentUrl('PAN', file?.path);
                      },
                    ),
                    const SizedBox(height: 16),

                    // MOA / AOA upload
                    DocUploadBox(
                      docType: 'MOA / AOA',
                      initialFilePath: campaign.moaAoaUrl,
                      onFilePicked: (file) {
                        notifier.updateDocumentUrl('MOA / AOA', file?.path);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Next button
            PrimaryButton(
              margin: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              text: 'Next',
              onTap: () {
                context.push('/start-campaign-4');
              },
            ),
          ],
        ),
      ),
    );
  }
}
