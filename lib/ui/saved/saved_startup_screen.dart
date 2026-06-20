import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/ui/saved/view_model/saved_campaign_view_model.dart';
import 'package:bostra/ui/saved/widgets/saved_search_field.dart';
import 'package:bostra/ui/saved/widgets/saved_startup_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavedStartupScreen extends ConsumerWidget {
  const SavedStartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedCampaigns =
        ref.watch(savedCampaignViewModelProvider).savedCampaigns;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Startups'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 0.6,
                  color: AppColors.blackColor.withAlpha(80),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 28),
          SavedSearchField(),
          const SizedBox(height: 24),

          Expanded(
            child: savedCampaigns.isEmpty
                ? const Center(
                    child: Text(
                      'No saved startups yet.\nTap the heart on any campaign to save it.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: savedCampaigns.length,
                    itemBuilder: (context, index) => SavedStartupCard(
                      campaign: savedCampaigns[index],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
