import 'package:bostra/models/founder_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// A founder invitation in the notifications inbox, with approve / reject.
class InvitationCard extends StatelessWidget {
  final FounderInvitationModel invitation;
  final bool isProcessing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const InvitationCard({
    super.key,
    required this.invitation,
    required this.isProcessing,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final hasLogo = invitation.companyLogoUrl != null &&
        invitation.companyLogoUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.blackColor.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryColor.withAlpha(30),
                backgroundImage:
                    hasLogo ? NetworkImage(invitation.companyLogoUrl!) : null,
                child: hasLogo
                    ? null
                    : Icon(LucideIcons.building_2,
                        color: AppColors.primaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: AppTextStyle.bodyText1
                            .copyWith(color: AppColors.blackColor),
                        children: [
                          const TextSpan(text: 'You\'ve been invited to join '),
                          TextSpan(
                            text: invitation.companyName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(text: ' as '),
                          TextSpan(
                            text: invitation.designation,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                    if (invitation.invitedByName != null &&
                        invitation.invitedByName!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Invited by ${invitation.invitedByName}',
                        style: AppTextStyle.bodyText3,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Reject',
                  isOutlined: true,
                  isLoading: isProcessing,
                  onTap: onReject,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Approve',
                  isOutlined: false,
                  isLoading: isProcessing,
                  onTap: onApprove,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isOutlined;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.isOutlined,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryColor;
    return SizedBox(
      height: 44,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onTap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.blackColor.withAlpha(60)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                label,
                style: AppTextStyle.normalText.copyWith(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onTap,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: primary,
                disabledBackgroundColor: primary.withAlpha(150),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: AppTextStyle.normalText.copyWith(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
    );
  }
}
