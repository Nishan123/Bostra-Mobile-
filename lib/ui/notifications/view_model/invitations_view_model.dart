import 'package:bostra/controllers/company_controller.dart';
import 'package:bostra/ui/company/view_model/my_companies_view_model.dart';
import 'package:bostra/ui/notifications/state/invitations_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final invitationsViewModelProvider =
    NotifierProvider<InvitationsViewModel, InvitationsState>(
  InvitationsViewModel.new,
);

/// Lightweight count of pending invitations — drives the dashboard bell badge.
final pendingInvitationCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final controller = ref.watch(companyControllerProvider);
  final result = await controller.getMyInvitations();
  return result.fold((_) => 0, (list) => list.length);
});

class InvitationsViewModel extends Notifier<InvitationsState> {
  late CompanyController _companyController;

  @override
  InvitationsState build() {
    _companyController = ref.read(companyControllerProvider);
    Future.microtask(fetchInvitations);
    return const InvitationsState();
  }

  Future<void> fetchInvitations() async {
    state = state.copyWith(
      status: InvitationsStatus.loading,
      errorMessage: null,
    );
    final result = await _companyController.getMyInvitations();
    result.fold(
      (failure) => state = state.copyWith(
        status: InvitationsStatus.error,
        errorMessage: failure.errorMessage,
      ),
      (invitations) => state = state.copyWith(
        status: InvitationsStatus.success,
        invitations: invitations,
      ),
    );
  }

  Future<bool> respond({
    required String invitationId,
    required bool accept,
  }) async {
    state = state.copyWith(
      actionStatus: InvitationActionStatus.loading,
      processingId: invitationId,
    );

    final result = await _companyController.respondToInvitation(
      invitationId: invitationId,
      accept: accept,
    );

    return await result.fold(
      (failure) async {
        state = state.copyWith(
          actionStatus: InvitationActionStatus.error,
          actionMessage: failure.errorMessage,
        );
        return false;
      },
      (_) async {
        final remaining =
            state.invitations.where((i) => i.id != invitationId).toList();
        state = state.copyWith(
          actionStatus: InvitationActionStatus.success,
          invitations: remaining,
          actionMessage:
              accept ? 'Invitation accepted.' : 'Invitation declined.',
        );

        // Refresh the badge count and the companies list (accepting joins one).
        ref.invalidate(pendingInvitationCountProvider);
        if (accept) {
          ref.read(myCompaniesViewModelProvider.notifier).fetchMyCompanies();
        }
        return true;
      },
    );
  }

  void resetActionStatus() =>
      state = state.copyWith(actionStatus: InvitationActionStatus.idle);
}
