import 'package:bostra/models/founder_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// A row describing one founder of a company.
class FounderTile extends StatelessWidget {
  final FounderModel founder;
  final bool canRemove;
  final VoidCallback? onRemove;

  const FounderTile({
    super.key,
    required this.founder,
    this.canRemove = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasPic =
        founder.profilePicUrl != null && founder.profilePicUrl!.isNotEmpty;
    final displayName = (founder.fullName != null &&
            founder.fullName!.trim().isNotEmpty)
        ? founder.fullName!
        : founder.phone;
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Container(
    
      decoration: BoxDecoration(
        border: Border.all(width: 0.4, color: AppColors.black10),
        borderRadius: BorderRadius.circular(8)
      ),
      padding: EdgeInsets.symmetric(horizontal: 6,vertical: 6),
      margin: EdgeInsets.only(bottom: 8,left: 12,right: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryColor.withAlpha(30),
            backgroundImage: hasPic ? NetworkImage(founder.profilePicUrl!) : null,
            child: hasPic
                ? null
                : Text(
                    initial,
                    style: AppTextStyle.h4.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyle.bodyText1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  founder.designation,
                  style: AppTextStyle.bodyText3,
                ),
              ],
            ),
          ),
          _StatusChip(founder: founder),
          if (canRemove && !founder.isOwner && onRemove != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onRemove,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                LucideIcons.trash_2,
                size: 18,
                color: AppColors.redColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final FounderModel founder;
  const _StatusChip({required this.founder});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;

    if (founder.isOwner) {
      label = 'Owner';
      color = AppColors.primaryColor;
    } else if (founder.isActive) {
      label = 'Active';
      color = AppColors.blueColor;
    } else if (founder.isRejected) {
      label = 'Declined';
      color = AppColors.redColor;
    } else {
      label = 'Pending';
      color = AppColors.secondryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyle.bodyText3.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
