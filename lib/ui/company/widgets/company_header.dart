import 'package:bostra/models/company_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Header block on the company detail screen: logo, name, verification status,
/// description and metadata rows.
class CompanyHeader extends StatelessWidget {
  final CompanyModel company;
  const CompanyHeader({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final hasLogo = company.logoUrl != null && company.logoUrl!.isNotEmpty;
    final location = [
      company.city,
      company.country,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primaryColor.withAlpha(30),
                backgroundImage:
                    hasLogo ? NetworkImage(company.logoUrl!) : null,
                child: hasLogo
                    ? null
                    : Text(
                        company.name.isNotEmpty
                            ? company.name[0].toUpperCase()
                            : '?',
                        style: AppTextStyle.h2.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(company.name, style: AppTextStyle.h2),
                    if (company.tagline != null &&
                        company.tagline!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(company.tagline!, style: AppTextStyle.bodyText2),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _VerificationBanner(isVerified: company.isVerified),
          const SizedBox(height: 12),
          if (company.description != null && company.description!.isNotEmpty)
            Text(company.description!, style: AppTextStyle.bodyText2),
          const SizedBox(height: 8),
          if (company.industry != null && company.industry!.isNotEmpty)
            _InfoRow(icon: LucideIcons.briefcase, value: company.industry!),
          if (location.isNotEmpty)
            _InfoRow(icon: LucideIcons.map_pin, value: location),
          if (company.registrationNumber != null &&
              company.registrationNumber!.isNotEmpty)
            _InfoRow(
              icon: LucideIcons.hash,
              value: company.registrationNumber!,
            ),
          if (company.website != null && company.website!.isNotEmpty)
            _InfoRow(icon: LucideIcons.globe, value: company.website!),
          if (company.email != null && company.email!.isNotEmpty)
            _InfoRow(icon: LucideIcons.mail, value: company.email!),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _InfoRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryColor),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: AppTextStyle.bodyText2)),
        ],
      ),
    );
  }
}

/// Verification status pill shown in the company header.
class _VerificationBanner extends StatelessWidget {
  final bool isVerified;
  const _VerificationBanner({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    final color =
        isVerified ? AppColors.primaryColor : AppColors.secondryColor;
    final icon = isVerified ? LucideIcons.circle_check_big : LucideIcons.clock;
    final label = isVerified ? 'Verified company' : 'Pending verification';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyle.bodyText3.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
