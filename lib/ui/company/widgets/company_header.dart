import 'package:bostra/models/company_model.dart';
import 'package:bostra/models/founder_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Header block on the company detail screen: logo on the left; name,
/// verification status, founder avatars + count, and the industry chip on the
/// right. Description and remaining metadata sit below.
class CompanyHeader extends StatelessWidget {
  final CompanyModel company;

  /// Active founders (owner + accepted members) used for the avatar summary.
  final List<FounderModel> founders;

  const CompanyHeader({
    super.key,
    required this.company,
    required this.founders,
  });

  @override
  Widget build(BuildContext context) {
    final hasLogo = company.logoUrl != null && company.logoUrl!.isNotEmpty;
    final imageSize =
        (MediaQuery.of(context).size.width * 0.36).clamp(120.0, 160.0);
    final location = [
      company.city,
      company.country,
    ].where((e) => e != null && e.isNotEmpty).join(', ');
    final founderCount = founders.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top block: logo + name / verified / founders / industry ──────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: hasLogo
                    ? Image.network(
                        company.logoUrl!,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: imageSize,
                        height: imageSize,
                        alignment: Alignment.center,
                        color: AppColors.primaryColor.withAlpha(30),
                        child: Text(
                          company.name.isNotEmpty
                              ? company.name[0].toUpperCase()
                              : '?',
                          style: AppTextStyle.heading.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: AppTextStyle.h1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // Verification status
                    Row(
                      children: [
                        Icon(
                          company.isVerified
                              ? Icons.verified
                              : LucideIcons.clock,
                          color: company.isVerified
                              ? AppColors.blueColor
                              : AppColors.secondryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          company.isVerified ? 'Verified' : 'Pending verification',
                          style: AppTextStyle.bodyText1,
                        ),
                      ],
                    ),

                    // Founder avatars + count
                    if (founderCount > 0) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _FounderAvatars(founders: founders),
                          const SizedBox(width: 8),
                          Text(
                            '$founderCount Founder${founderCount == 1 ? '' : 's'}',
                            style: AppTextStyle.h4,
                          ),
                        ],
                      ),
                    ],

                    // Industry chip
                    if (company.industry != null &&
                        company.industry!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          company.industry!,
                          style: AppTextStyle.bodyText2.copyWith(
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // ── Description + remaining metadata ─────────────────────────────
          if (company.description != null &&
              company.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(company.description!, style: AppTextStyle.bodyText2),
          ],
          const SizedBox(height: 8),
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

/// Overlapping avatar stack for up to three founders (grey placeholders when a
/// founder has no profile picture).
class _FounderAvatars extends StatelessWidget {
  final List<FounderModel> founders;
  const _FounderAvatars({required this.founders});

  static const double _size = 34;
  static const double _overlap = 12;

  @override
  Widget build(BuildContext context) {
    final visible = founders.take(3).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    final stackWidth = _size + (visible.length - 1) * (_size - _overlap);

    return SizedBox(
      width: stackWidth,
      height: _size,
      child: Stack(
        children: List.generate(visible.length, (i) {
          final f = visible[i];
          final hasPic =
              f.profilePicUrl != null && f.profilePicUrl!.isNotEmpty;
          return Positioned(
            left: i * (_size - _overlap),
            child: Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blackColor.withAlpha(20),
                border: Border.all(color: AppColors.whiteColor, width: 2),
                image: hasPic
                    ? DecorationImage(
                        image: NetworkImage(f.profilePicUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
          );
        }).reversed.toList(),
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
