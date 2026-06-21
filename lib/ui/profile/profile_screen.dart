import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/auth/state/auth_state.dart';
import 'package:bostra/ui/auth/view_models/auth_view_model.dart';
import 'package:bostra/ui/profile/state/profile_state.dart';
import 'package:bostra/ui/profile/view_model/profile_view_model.dart';
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
    final profileState = ref.watch(profileViewModelProvider);

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

    final user = profileState.user;
    final isLoadingProfile = profileState.status == ProfileStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
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
      body: isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : profileState.status == ProfileStatus.error
              ? _ErrorState(
                  message: profileState.errorMessage ?? 'Failed to load profile.',
                  onRetry: () =>
                      ref.read(profileViewModelProvider.notifier).fetchCurrentUser(),
                )
              : _ProfileBody(
                  authState: authState,
                  ref: ref,
                  user: user,
                ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile body — shown when data is loaded
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.authState,
    required this.ref,
    required this.user,
  });

  final AuthState authState;
  final WidgetRef ref;
  final dynamic user; // UserModel?

  @override
  Widget build(BuildContext context) {
    final fullName = user?.fullName ?? '—';
    final phone = user?.phone ?? '—';
    final dob = user?.dob ?? '—';
    final address = user?.address ?? '—';

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primaryColor.withAlpha(30),
            backgroundImage: user?.profilePicUrl != null && user!.profilePicUrl!.isNotEmpty
                ? NetworkImage(user!.profilePicUrl!)
                : null,
            child: user?.profilePicUrl != null && user!.profilePicUrl!.isNotEmpty
                ? null
                : Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
          ),
          const SizedBox(height: 8),

          // Name
          Text(fullName, style: AppTextStyle.h2),
          const SizedBox(height: 4),
          const InfoChip(text: "Investor / Owner"),

          const SizedBox(height: 20),

          // Info rows
          _InfoTile(icon: LucideIcons.phone, label: 'Phone', value: phone),
          _InfoTile(icon: LucideIcons.calendar, label: 'Date of Birth', value: dob),
          _InfoTile(icon: LucideIcons.map_pin, label: 'Address', value: address),

          Divider(
            thickness: 0.6,
            endIndent: 12,
            indent: 12,
            height: 28,
          ),

          // Stat Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    variant: StatCardVariant.purple,
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
                    variant: StatCardVariant.amber,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          PrimaryButton(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            text: "Start your campaign",
            onTap: () => context.pushNamed("startCampaign1"),
          ),
          const SizedBox(height: 12),

          PrimaryButton(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            backgroundColor: AppColors.redColor,
            text: "Log Out",
            onTap: () =>
                ref.read(authViewModelProvider.notifier).signOut(),
            isLoading: authState.status == AuthStatus.loading,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info tile — a labelled row for user details
// ─────────────────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyle.bodyText3),
                Text(value, style: AppTextStyle.bodyText1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state widget
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.redColor),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyText1),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
