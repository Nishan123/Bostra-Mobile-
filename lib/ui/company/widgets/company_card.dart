import 'package:bostra/models/company_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// A tappable summary card for a company in the "My Companies" list.
class CompanyCard extends StatelessWidget {
  final CompanyModel company;
  final VoidCallback onTap;

  const CompanyCard({
    super.key,
    required this.company,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasLogo = company.logoUrl != null && company.logoUrl!.isNotEmpty;
    final subtitle = (company.tagline != null && company.tagline!.isNotEmpty)
        ? company.tagline!
        : (company.industry ?? '');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryColor.withAlpha(30),
                  backgroundImage: hasLogo ? NetworkImage(company.logoUrl!) : null,
                  child: hasLogo
                      ? null
                      : Text(
                          company.name.isNotEmpty
                              ? company.name[0].toUpperCase()
                              : '?',
                          style: AppTextStyle.h3.copyWith(
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
                        company.name,
                        style: AppTextStyle.h4,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTextStyle.bodyText3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                _RoleBadge(isOwner: company.isOwner),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MetaChip(
                  icon: LucideIcons.users,
                  label: '${company.founderCount ?? 0} founders',
                ),
                const SizedBox(width: 10),
                _MetaChip(
                  icon: LucideIcons.rocket,
                  label: '${company.campaignCount ?? 0} campaigns',
                ),
                const Spacer(),
                _VerifyChip(isVerified: company.isVerified),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final bool isOwner;
  const _RoleBadge({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final color = isOwner ? AppColors.primaryColor : AppColors.blueColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOwner ? 'Owner' : 'Founder',
        style: AppTextStyle.bodyText3.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _VerifyChip extends StatelessWidget {
  final bool isVerified;
  const _VerifyChip({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    final color =
        isVerified ? AppColors.primaryColor : AppColors.secondryColor;
    final icon = isVerified ? LucideIcons.circle_check_big : LucideIcons.clock;
    final label = isVerified ? 'Verified' : 'Verification pending';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyle.bodyText3.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.blackColor.withAlpha(140)),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyle.bodyText3,
        ),
      ],
    );
  }
}
