import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/startup_details/widget/sd_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Company identity row on the startup details screen: logo, name, verification
/// status.
class SdCompanyRow extends StatelessWidget {
  final CampaignModel campaign;
  const SdCompanyRow({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    final c = campaign;
    return SdSection(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.turnaryColor,
            backgroundImage: c.logoUrl != null ? NetworkImage(c.logoUrl!) : null,
            child: c.logoUrl == null
                ? Text(
                    c.startupName.isNotEmpty
                        ? c.startupName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        c.startupName,
                        style: AppTextStyle.h4,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    if (c.isVerified)
                      Icon(
                        LucideIcons.circle_check_big,
                        color: AppColors.blueColor,
                        size: 16,
                      ),
                  ],
                ),
                Text(
                  c.isVerified ? 'Verified' : 'Pending verification',
                  style: AppTextStyle.bodyText3,
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevron_right, color: AppColors.black10, size: 20),
        ],
      ),
    );
  }
}
