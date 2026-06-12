import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/start_campain/widgets/campain_app_bar.dart';
import 'package:bostra/ui/start_campain/widgets/doc_upload_box.dart';
import 'package:bostra/ui/start_campain/widgets/start_campain_progress.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartCampain3 extends StatelessWidget {
  const StartCampain3({super.key});

  @override
  Widget build(BuildContext context) {
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
                      totalSteps: 4,
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
                    const DocUploadBox(docType: 'Company Registration'),
                    const SizedBox(height: 16),

                    // PAN upload
                    const DocUploadBox(docType: 'PAN'),
                    const SizedBox(height: 16),

                    // MOA / AOA upload
                    const DocUploadBox(docType: 'MOA / AOA'),
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
