import 'package:equatable/equatable.dart';

/// Founder roles within a company.
class FounderRole {
  static const String owner = 'owner';
  static const String founder = 'founder';
}

/// Founder / invitation lifecycle status.
class FounderStatus {
  static const String pending = 'pending';
  static const String active = 'active';
  static const String rejected = 'rejected';
}

/// A founder of a company — either the owner or an invited member. Maps the
/// `get_company_founders` RPC and direct `company_founders` rows.
class FounderModel extends Equatable {
  final String? id;
  final String? companyId;
  final String? userId;
  final String phone;
  final String? fullName;
  final String designation;
  final String role;
  final String status;
  final String? invitedBy;
  final DateTime? createdAt;
  final DateTime? respondedAt;
  final String? profilePicUrl;

  const FounderModel({
    this.id,
    this.companyId,
    this.userId,
    this.phone = '',
    this.fullName,
    this.designation = '',
    this.role = FounderRole.founder,
    this.status = FounderStatus.pending,
    this.invitedBy,
    this.createdAt,
    this.respondedAt,
    this.profilePicUrl,
  });

  bool get isOwner => role == FounderRole.owner;
  bool get isActive => status == FounderStatus.active;
  bool get isPending => status == FounderStatus.pending;
  bool get isRejected => status == FounderStatus.rejected;

  factory FounderModel.fromJson(Map<String, dynamic> json) {
    return FounderModel(
      id: json['id'] as String?,
      companyId: json['company_id'] as String?,
      userId: json['user_id'] as String?,
      phone: json['phone'] as String? ?? '',
      fullName: json['full_name'] as String?,
      designation: json['designation'] as String? ?? '',
      role: json['role'] as String? ?? FounderRole.founder,
      status: json['status'] as String? ?? FounderStatus.pending,
      invitedBy: json['invited_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      profilePicUrl: json['profile_pic_url'] as String?,
    );
  }

  FounderModel copyWith({
    String? id,
    String? companyId,
    String? userId,
    String? phone,
    String? fullName,
    String? designation,
    String? role,
    String? status,
    String? invitedBy,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? profilePicUrl,
  }) {
    return FounderModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      designation: designation ?? this.designation,
      role: role ?? this.role,
      status: status ?? this.status,
      invitedBy: invitedBy ?? this.invitedBy,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        userId,
        phone,
        fullName,
        designation,
        role,
        status,
        invitedBy,
        createdAt,
        respondedAt,
        profilePicUrl,
      ];
}

/// A pending invitation addressed to the current user, shown in the
/// notifications inbox. Maps the `get_my_founder_invitations` RPC.
class FounderInvitationModel extends Equatable {
  final String id;
  final String companyId;
  final String companyName;
  final String? companyLogoUrl;
  final String designation;
  final String status;
  final String? invitedByName;
  final DateTime? createdAt;

  const FounderInvitationModel({
    required this.id,
    required this.companyId,
    required this.companyName,
    this.companyLogoUrl,
    required this.designation,
    this.status = FounderStatus.pending,
    this.invitedByName,
    this.createdAt,
  });

  factory FounderInvitationModel.fromJson(Map<String, dynamic> json) {
    return FounderInvitationModel(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      companyName: json['company_name'] as String? ?? 'A company',
      companyLogoUrl: json['company_logo_url'] as String?,
      designation: json['designation'] as String? ?? '',
      status: json['status'] as String? ?? FounderStatus.pending,
      invitedByName: json['invited_by_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        companyName,
        companyLogoUrl,
        designation,
        status,
        invitedByName,
        createdAt,
      ];
}
