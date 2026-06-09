import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/widgets/avatars_with_count.dart';
import 'package:bostra/widgets/fund_progress_bar.dart';
import 'package:bostra/widgets/info_chip.dart';
import 'package:flutter/material.dart';

class MyStartupCard extends StatelessWidget {
  final double collectedAmount;
  final double requestedAmount;
  const MyStartupCard({super.key, required this.collectedAmount, required this.requestedAmount});
  

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(left: 14, right: 14, bottom: 18),
      padding: EdgeInsets.only(bottom: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          width: 0.6,
          color: AppColors.primaryColor.withValues(alpha: 0.40),
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          // image container
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            clipBehavior: .hardEdge,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.turnaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22.1),
                topRight: Radius.circular(22.1),
              ),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  child: Image.network(
                    "https://images.pexels.com/photos/3952080/pexels-photo-3952080.jpeg",
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),

                //like button
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    spacing: 2,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                    InfoChip(text: "Hello"),
                      InfoChip(text: "Hello"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                // title text
                Text(
                  "Start up title not more than one line and other thing",
                  style: AppTextStyle.h2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // fund progress
                FundProgressBar(),

                // amount raised text
                Row(
                  spacing: 8,
                  children: [
                    Text(
                      "Rs ${collectedAmount.toStringAsFixed(0).toString()}",
                      style: AppTextStyle.h3,
                    ),
                    Text("Raised of"),
                    Text("Rs ${requestedAmount.toStringAsFixed(0).toString()}"),
                  ],
                ),

                Row(
                  children: [
                    AvatarsWithCount(
                      imageUrls: [
                        "https://images.pexels.com/photos/10143324/pexels-photo-10143324.jpeg",
                        "https://images.pexels.com/photos/10143324/pexels-photo-10143324.jpeg",
                        "https://images.pexels.com/photos/10143324/pexels-photo-10143324.jpeg",
                        "https://images.pexels.com/photos/10143324/pexels-photo-10143324.jpeg",
                      ],
                      totalBackers: 4,
                      avatarSize: 40,
                    ),
                    Spacer(),
                    InfoChip(text: "4 days left"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}