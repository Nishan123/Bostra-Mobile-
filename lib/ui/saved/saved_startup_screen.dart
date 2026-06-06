import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/ui/saved/widgets/saved_startup_card.dart';
import 'package:flutter/material.dart';

class SavedStartupScreen extends StatelessWidget {
  const SavedStartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Startups"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 10,
              itemBuilder: (context, index) {
                return SavedStartupCard();
              },
            ),
          ],
        ),
      ),
    );
  }
}
