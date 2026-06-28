import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/notifications/state/invitations_state.dart';
import 'package:bostra/ui/notifications/view_model/invitations_view_model.dart';
import 'package:bostra/ui/notifications/widgets/invitation_card.dart';
import 'package:bostra/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(invitationsViewModelProvider.notifier).fetchInvitations(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<InvitationsState>(invitationsViewModelProvider,
        (previous, next) {
      if (next.actionStatus == InvitationActionStatus.success) {
        CustomSnackBar.showSuccessSnackBar(
          context,
          next.actionMessage ?? 'Done.',
        );
        ref.read(invitationsViewModelProvider.notifier).resetActionStatus();
      } else if (next.actionStatus == InvitationActionStatus.error) {
        CustomSnackBar.showErrorSnackBar(
          context,
          next.actionMessage ?? 'Action failed.',
        );
        ref.read(invitationsViewModelProvider.notifier).resetActionStatus();
      }
    });

    final state = ref.watch(invitationsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 0.6,
            color: AppColors.blackColor.withAlpha(80),
          ),
        ),
      ),
      body: SafeArea(child: _buildBody(state)),
    );
  }

  Widget _buildBody(InvitationsState state) {
    switch (state.status) {
      case InvitationsStatus.initial:
      case InvitationsStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case InvitationsStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.circle_alert,
                    size: 48, color: AppColors.redColor),
                const SizedBox(height: 12),
                Text(state.errorMessage ?? 'Failed to load notifications.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref
                      .read(invitationsViewModelProvider.notifier)
                      .fetchInvitations(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );

      case InvitationsStatus.success:
        if (state.invitations.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => ref
                .read(invitationsViewModelProvider.notifier)
                .fetchInvitations(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.bell_off,
                            size: 56,
                            color: AppColors.blackColor.withAlpha(80)),
                        const SizedBox(height: 16),
                        Text('You\'re all caught up',
                            style: AppTextStyle.h3),
                        const SizedBox(height: 6),
                        Text('No pending invitations right now.',
                            style: AppTextStyle.bodyText2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref
              .read(invitationsViewModelProvider.notifier)
              .fetchInvitations(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.invitations.length,
            itemBuilder: (context, index) {
              final invitation = state.invitations[index];
              final isProcessing = state.processingId == invitation.id &&
                  state.actionStatus == InvitationActionStatus.loading;
              return InvitationCard(
                invitation: invitation,
                isProcessing: isProcessing,
                onApprove: () => ref
                    .read(invitationsViewModelProvider.notifier)
                    .respond(invitationId: invitation.id, accept: true),
                onReject: () => ref
                    .read(invitationsViewModelProvider.notifier)
                    .respond(invitationId: invitation.id, accept: false),
              );
            },
          ),
        );
    }
  }
}
