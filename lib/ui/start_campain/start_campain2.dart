import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/start_campain/widgets/campain_app_bar.dart';
import 'package:bostra/ui/start_campain/widgets/campaign_textfield.dart';
import 'package:bostra/ui/start_campain/widgets/start_campain_progress.dart';
import 'package:bostra/ui/start_campain/view_model/start_campaign_view_model.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StartCampain2 extends ConsumerStatefulWidget {
  const StartCampain2({super.key});

  @override
  ConsumerState<StartCampain2> createState() => _StartCampain2State();
}

class _StartCampain2State extends ConsumerState<StartCampain2> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _problemController;
  late final TextEditingController _solutionController;
  late final TextEditingController _audienceController;
  late final TextEditingController _uspController;

  @override
  void initState() {
    super.initState();
    final campaign = ref.read(campaignViewModelProvider).campaign;
    _descriptionController = TextEditingController(text: campaign.description);
    _problemController = TextEditingController(text: campaign.problemStatement);
    _solutionController = TextEditingController(text: campaign.solution);
    _audienceController = TextEditingController(text: campaign.targetAudience);
    _uspController = TextEditingController(text: campaign.uniqueSellingPoint);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _problemController.dispose();
    _solutionController.dispose();
    _audienceController.dispose();
    _uspController.dispose();
    super.dispose();
  }

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
                    const StartCampainProgress(currentStep: 2, totalSteps: 5),

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
                    CampaignTextfield(
                      label: 'Description',
                      hintText: 'Write a brief description of your startup',
                      maxLines: 4,
                      controller: _descriptionController,
                      onChanged: (value) {
                        ref.read(campaignViewModelProvider.notifier).updateDescription(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Problem statement
                    CampaignTextfield(
                      label: 'Problem statement',
                      hintText: 'What problem does your startup solve?',
                      maxLines: 3,
                      controller: _problemController,
                      onChanged: (value) {
                        ref.read(campaignViewModelProvider.notifier).updateProblemStatement(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Solution
                    CampaignTextfield(
                      label: 'Solution',
                      hintText: 'How does your startup solve it?',
                      maxLines: 3,
                      controller: _solutionController,
                      onChanged: (value) {
                        ref.read(campaignViewModelProvider.notifier).updateSolution(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Target audience
                    CampaignTextfield(
                      label: 'Target audience',
                      hintText: 'Who is your target audience?',
                      maxLines: 2,
                      controller: _audienceController,
                      onChanged: (value) {
                        ref.read(campaignViewModelProvider.notifier).updateTargetAudience(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Unique selling point
                    CampaignTextfield(
                      label: 'Unique selling point',
                      hintText: 'What makes your startup unique?',
                      maxLines: 2,
                      controller: _uspController,
                      onChanged: (value) {
                        ref.read(campaignViewModelProvider.notifier).updateUniqueSellingPoint(value);
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
                final notifier = ref.read(campaignViewModelProvider.notifier);
                notifier.updateDescription(_descriptionController.text);
                notifier.updateProblemStatement(_problemController.text);
                notifier.updateSolution(_solutionController.text);
                notifier.updateTargetAudience(_audienceController.text);
                notifier.updateUniqueSellingPoint(_uspController.text);
                context.push('/start-campaign-3');
              },
            ),
          ],
        ),
      ),
    );
  }
}
