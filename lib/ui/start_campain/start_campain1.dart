import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/start_campain/widgets/campain_app_bar.dart';
import 'package:bostra/ui/start_campain/widgets/campaign_textfield.dart';
import 'package:bostra/ui/start_campain/widgets/cover_image_picker.dart';
import 'package:bostra/ui/start_campain/widgets/industry_dropdown.dart';
import 'package:bostra/ui/start_campain/widgets/month_projection_card.dart';
import 'package:bostra/ui/start_campain/widgets/start_campain_progress.dart';
import 'package:bostra/ui/start_campain/view_model/start_campaign_view_model.dart';
import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StartCampain1 extends ConsumerStatefulWidget {
  const StartCampain1({super.key});

  @override
  ConsumerState<StartCampain1> createState() => _StartCampain1State();
}

class _StartCampain1State extends ConsumerState<StartCampain1> {
  late final TextEditingController _nameController;
  late final TextEditingController _taglineController;
  String? _selectedIndustry;

  @override
  void initState() {
    super.initState();
    final campaign = ref.read(campaignViewModelProvider).campaign;
    _nameController = TextEditingController(text: campaign.startupName);
    _taglineController = TextEditingController(text: campaign.shortTagline);
    _selectedIndustry = campaign.industry.isEmpty ? null : campaign.industry;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  MonthProjection _getProjection(int monthNumber, String monthLabel) {
    final projections = ref.read(campaignViewModelProvider).campaign.monthProjections;
    return projections.firstWhere(
      (p) => p.monthNumber == monthNumber,
      orElse: () => MonthProjection(monthNumber: monthNumber, monthLabel: monthLabel),
    );
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
                    const StartCampainProgress(currentStep: 1, totalSteps: 4),

                    const SizedBox(height: 16),

                    // Introductions section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Introductions',
                        style: AppTextStyle.h2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Startup name
                    CampaignTextfield(
                      label: 'Startup name',
                      hintText: 'Example : Bluetooth umbrella',
                      controller: _nameController,
                      onChanged: (value) {
                        ref.read(campaignViewModelProvider.notifier).updateStartupName(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Short tagline
                    CampaignTextfield(
                      label: 'Short tagline',
                      hintText: 'Describe your startup in one shot',
                      controller: _taglineController,
                      onChanged: (value) {
                        ref.read(campaignViewModelProvider.notifier).updateShortTagline(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Industry dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: IndustryDropdown(
                        selectedIndustry: _selectedIndustry,
                        onChanged: (value) {
                          setState(() {
                            _selectedIndustry = value;
                          });
                          if (value != null) {
                            ref.read(campaignViewModelProvider.notifier).updateIndustry(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Cover image
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Cover Image', style: AppTextStyle.h2),
                    ),
                    const SizedBox(height: 12),
                    CoverImagePicker(
                      initialImagePaths: ref
                          .read(campaignViewModelProvider)
                          .campaign
                          .galleryImageUrls,
                      onImagesChanged: (files) {
                        ref
                            .read(campaignViewModelProvider.notifier)
                            .updateCoverImages(
                              files.map((f) => f.path).toList(),
                            );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Vision & 3 month projection
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Vision & 3 month projection',
                        style: AppTextStyle.h2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Month 1
                    MonthProjectionCard(
                      monthNumber: 1,
                      monthLabel: 'Jan 2027',
                      initialObjectives: _getProjection(1, 'Jan 2027').objectives,
                      initialGoals: _getProjection(1, 'Jan 2027').goals,
                      initialInitiative: _getProjection(1, 'Jan 2027').initiative,
                      onObjectivesChanged: (val) {
                        ref.read(campaignViewModelProvider.notifier).updateMonthProjection(
                              1,
                              'Jan 2027',
                              objectives: val,
                            );
                      },
                      onGoalsChanged: (val) {
                        ref.read(campaignViewModelProvider.notifier).updateMonthProjection(
                              1,
                              'Jan 2027',
                              goals: val,
                            );
                      },
                      onInitiativeChanged: (val) {
                        ref.read(campaignViewModelProvider.notifier).updateMonthProjection(
                              1,
                              'Jan 2027',
                              initiative: val,
                            );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Month 2
                    MonthProjectionCard(
                      monthNumber: 2,
                      monthLabel: 'Feb 2027',
                      initialObjectives: _getProjection(2, 'Feb 2027').objectives,
                      initialGoals: _getProjection(2, 'Feb 2027').goals,
                      initialInitiative: _getProjection(2, 'Feb 2027').initiative,
                      onObjectivesChanged: (val) {
                        ref.read(campaignViewModelProvider.notifier).updateMonthProjection(
                              2,
                              'Feb 2027',
                              objectives: val,
                            );
                      },
                      onGoalsChanged: (val) {
                        ref.read(campaignViewModelProvider.notifier).updateMonthProjection(
                              2,
                              'Feb 2027',
                              goals: val,
                            );
                      },
                      onInitiativeChanged: (val) {
                        ref.read(campaignViewModelProvider.notifier).updateMonthProjection(
                              2,
                              'Feb 2027',
                              initiative: val,
                            );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Month 3
                    MonthProjectionCard(
                      monthNumber: 3,
                      monthLabel: 'Mar 2027',
                      initialObjectives: _getProjection(3, 'Mar 2027').objectives,
                      initialGoals: _getProjection(3, 'Mar 2027').goals,
                      initialInitiative: _getProjection(3, 'Mar 2027').initiative,
                      onObjectivesChanged: (val) {
                        ref.read(campaignViewModelProvider.notifier).updateMonthProjection(
                              3,
                              'Mar 2027',
                              objectives: val,
                            );
                      },
                      onGoalsChanged: (val) {
                        ref.read(campaignViewModelProvider.notifier).updateMonthProjection(
                              3,
                              'Mar 2027',
                              goals: val,
                            );
                      },
                      onInitiativeChanged: (val) {
                        ref.read(campaignViewModelProvider.notifier).updateMonthProjection(
                              3,
                              'Mar 2027',
                              initiative: val,
                            );
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
                // Perform a final update to make sure everything is in sync
                ref.read(campaignViewModelProvider.notifier).updateStartupName(_nameController.text);
                ref.read(campaignViewModelProvider.notifier).updateShortTagline(_taglineController.text);
                if (_selectedIndustry != null) {
                  ref.read(campaignViewModelProvider.notifier).updateIndustry(_selectedIndustry!);
                }
                context.push('/start-campaign-2');
              },
            ),
          ],
        ),
      ),
    );
  }
}