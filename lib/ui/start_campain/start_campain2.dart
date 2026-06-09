import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/start_campain/widgets/campain_app_bar.dart';
import 'package:bostra/ui/start_campain/widgets/campaign_textfield.dart';
import 'package:bostra/ui/start_campain/widgets/start_campain_progress.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartCampain2 extends StatelessWidget {
  const StartCampain2({super.key});

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
                    const StartCampainProgress(currentStep: 2),

                    const SizedBox(height: 16),

                    // Tell us more section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Tell us more about your startup',
                        style: AppTextStyle.h2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CampaignTextfield(
                        label: 'Description',
                        hintText: 'Write a brief description of your startup',
                        maxLines: 4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Problem statement
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CampaignTextfield(
                        label: 'Problem statement',
                        hintText: 'What problem does your startup solve?',
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Solution
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CampaignTextfield(
                        label: 'Solution',
                        hintText: 'How does your startup solve it?',
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Target audience
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CampaignTextfield(
                        label: 'Target audience',
                        hintText: 'Who is your target audience?',
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Unique selling point
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CampaignTextfield(
                        label: 'Unique selling point',
                        hintText: 'What makes your startup unique?',
                        maxLines: 2,
                      ),
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
                context.push('/start-campaign-3');
              },
            ),
          ],
        ),
      ),
    );
  }
}
