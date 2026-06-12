import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/start_campain/widgets/campain_app_bar.dart';
import 'package:bostra/ui/start_campain/widgets/campaign_textfield.dart';
import 'package:bostra/ui/start_campain/widgets/industry_dropdown.dart';
import 'package:bostra/ui/start_campain/widgets/month_projection_card.dart';
import 'package:bostra/ui/start_campain/widgets/start_campain_progress.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StartCampain1 extends StatefulWidget {
  const StartCampain1({super.key});

  @override
  State<StartCampain1> createState() => _StartCampain1State();
}

class _StartCampain1State extends State<StartCampain1> {
  String? _selectedIndustry;

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
                    const StartCampainProgress(currentStep: 1,totalSteps: 4,),

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
                    ),
                    const SizedBox(height: 16),

                    // Short tagline
                    CampaignTextfield(
                      label: 'Short tagline',
                      hintText: 'Describe your startup in one shot',
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
                        },
                      ),
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
                    const MonthProjectionCard(
                      monthNumber: 1,
                      monthLabel: 'Jan 2027',
                    ),
                    const SizedBox(height: 16),

                    // Month 2
                    const MonthProjectionCard(
                      monthNumber: 2,
                      monthLabel: 'Feb 2027',
                    ),
                    const SizedBox(height: 16),

                    // Month 3
                    const MonthProjectionCard(
                      monthNumber: 3,
                      monthLabel: 'Mar 2027',
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
                context.push('/start-campaign-2');
              },
            ),
          ],
        ),
      ),
    );
  }
}