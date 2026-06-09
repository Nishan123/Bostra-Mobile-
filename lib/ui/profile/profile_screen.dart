import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/auth/state/auth_state.dart';
import 'package:bostra/ui/auth/view_models/auth_view_model.dart';
import 'package:bostra/ui/profile/widgets/stat_card.dart';
import 'package:bostra/widgets/info_chip.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.initial) {
        context.goNamed("login");
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? "Sign out failed"),
            backgroundColor: Colors.redAccent,
          ),
        );
        ref.read(authViewModelProvider.notifier).resetStatus();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
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
      body: Column(
        children: [
          SizedBox(height: 24),
          CircleAvatar(radius: 60, backgroundColor: AppColors.black10),
          Text("Click to edit", style: AppTextStyle.bodyText2),
          Text("Full Name", style: AppTextStyle.h2),
          InfoChip(text: "Investor / Owner"),

          SizedBox(height: 25,),


          Divider(thickness: 0.6, endIndent: 12, indent: 12),
          SizedBox(height: 2),

          //My Company
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              spacing: 12,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.turnaryColor,
                  radius: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          Text("Startup name", style: AppTextStyle.h4),
                          Icon(
                            LucideIcons.circle_check_big,
                            color: AppColors.blueColor,
                          ),
                        ],
                      ),
                      Text("Company name", style: AppTextStyle.bodyText2),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevron_right,color: AppColors.black10,)
              ],
            ),
          ),
          SizedBox(height: 2),
          Divider(thickness: 0.6, endIndent: 12, indent: 12),

          SizedBox(height: 20),
          // Stat Card
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 12),
            child: Row(
              spacing: 4,
              children: [
                Expanded(
                  child: StatCard(
                    title: "Total Investments",
                    data: 24000,
                    prefix: "Rs ",
                    icon: LucideIcons.move_up_right,
                  ),
                ),
                Expanded(
                  child: StatCard(
                    title: "Active Campaigns",
                    data: 2,
                    icon: LucideIcons.building,
                  ),
                ),
                Expanded(
                  child: StatCard(
                    title: "Average Returns",
                    data: 12.4,
                    prefix: "+",
                    suffix: "%",
                    isInt: false,
                    icon: LucideIcons.percent,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          PrimaryButton(
            margin: EdgeInsets.symmetric(horizontal: 12),
            text: "Start your campaign",
            onTap: () {
              context.pushNamed("startCampaign1");
            },
          ),
          SizedBox(height: 12),

          PrimaryButton(
            margin: EdgeInsets.symmetric(horizontal: 12),
            backgroundColor: AppColors.redColor,
            text: "Log Out",
            onTap: () {
              ref.read(authViewModelProvider.notifier).signOut();
            },
            isLoading: authState.status == AuthStatus.loading,
          ),
        ],
      ),
    );
  }
}
