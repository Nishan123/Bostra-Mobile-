import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/company/state/company_detail_state.dart';
import 'package:bostra/ui/company/widgets/founder_tile.dart';
import 'package:bostra/widgets/widget_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

/// Founders section of the company detail screen — title, owner-only invite
/// action, and the list of founders.
class FoundersSection extends StatelessWidget {
  final CompanyDetailState state;
  final VoidCallback onInvite;
  final void Function(String founderId, String name) onRemove;

  const FoundersSection({
    super.key,
    required this.state,
    required this.onInvite,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final founders = state.founders;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: WidgetTitle(text: 'Founders (${founders.length})'),
            ),
            if (state.isOwner)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton.icon(
                  onPressed: onInvite,
                  icon: Icon(
                    LucideIcons.user_plus,
                    size: 18,
                    color: AppColors.primaryColor,
                  ),
                  label: Text(
                    'Invite',
                    style: TextStyle(color: AppColors.primaryColor),
                  ),
                ),
              ),
          ],
        ),
        if (founders.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 16, 8),
            child: Text('No founders yet.', style: AppTextStyle.bodyText2),
          )
        else
          ...founders.map(
            (f) => FounderTile(
              founder: f,
              canRemove: state.isOwner,
              onRemove: () => onRemove(
                f.id!,
                (f.fullName != null && f.fullName!.isNotEmpty)
                    ? f.fullName!
                    : f.phone,
              ),
            ),
          ),
      ],
    );
  }
}
