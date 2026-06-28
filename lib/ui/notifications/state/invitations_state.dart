import 'package:bostra/models/founder_model.dart';

enum InvitationsStatus { initial, loading, success, error }

enum InvitationActionStatus { idle, loading, success, error }

class InvitationsState {
  final InvitationsStatus status;
  final String? errorMessage;
  final List<FounderInvitationModel> invitations;

  /// Action feedback for approve / reject.
  final InvitationActionStatus actionStatus;
  final String? actionMessage;

  /// Id of the invitation currently being responded to (drives per-card spinner).
  final String? processingId;

  const InvitationsState({
    this.status = InvitationsStatus.initial,
    this.errorMessage,
    this.invitations = const [],
    this.actionStatus = InvitationActionStatus.idle,
    this.actionMessage,
    this.processingId,
  });

  bool get isEmpty =>
      status == InvitationsStatus.success && invitations.isEmpty;

  InvitationsState copyWith({
    InvitationsStatus? status,
    String? errorMessage,
    List<FounderInvitationModel>? invitations,
    InvitationActionStatus? actionStatus,
    String? actionMessage,
    String? processingId,
  }) {
    return InvitationsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      invitations: invitations ?? this.invitations,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage ?? this.actionMessage,
      processingId: processingId,
    );
  }
}
