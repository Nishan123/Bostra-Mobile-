import 'dart:io';

import 'package:bostra/constants/table_names.dart';
import 'package:bostra/failure/failure.dart';
import 'package:bostra/models/company_model.dart';
import 'package:bostra/models/founder_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final companyControllerProvider = Provider((ref) {
  return CompanyController();
});

/// Handles all company + founder + invitation data access against Supabase.
class CompanyController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ── Companies ──────────────────────────────────────────────────────────────

  /// Inserts a new company owned by the current user.
  Future<Either<Failure, CompanyModel>> createCompany(
    CompanyModel company,
  ) async {
    try {
      final ownerId = _supabase.auth.currentUser?.id;
      if (ownerId == null) {
        return const Left(ApiFailure(message: 'No authenticated user found.'));
      }
      final data = company.copyWith(ownerId: ownerId).toInsertJson();
      final response = await _supabase
          .from(TableNames.companiesTable)
          .insert(data)
          .select()
          .single();
      return Right(CompanyModel.fromJson(response).copyWith(myRole: 'owner'));
    } catch (e) {
      final text = e.toString();
      if (text.contains('companies_owner_unique') ||
          text.contains('duplicate key')) {
        return const Left(ApiFailure(
          message: 'You can only register one company per account.',
        ));
      }
      return Left(ApiFailure(message: 'Failed to create company: $e'));
    }
  }

  /// Whether the current user already owns a company (one-company-per-account
  /// rule). Used to gate the registration entry point.
  Future<Either<Failure, bool>> ownsCompany() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return const Right(false);
      final response = await _supabase
          .from(TableNames.companiesTable)
          .select('id')
          .eq('owner_id', userId)
          .maybeSingle();
      return Right(response != null);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to check ownership: $e'));
    }
  }

  /// Updates editable fields of a company the user owns.
  Future<Either<Failure, CompanyModel>> updateCompany(
    CompanyModel company,
  ) async {
    try {
      if (company.id == null) {
        return const Left(GeneralFailure('Company id is required.'));
      }
      final response = await _supabase
          .from(TableNames.companiesTable)
          .update(company.toInsertJson())
          .eq('id', company.id!)
          .select()
          .single();
      return Right(CompanyModel.fromJson(response));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to update company: $e'));
    }
  }

  /// Companies the current user owns or is an active founder of (with counts).
  Future<Either<Failure, List<CompanyModel>>> getMyCompanies() async {
    try {
      final response = await _supabase.rpc('get_my_companies');
      final companies = (response as List<dynamic>)
          .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(companies);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to fetch companies: $e'));
    }
  }

  /// Fetches a single company by id and resolves the viewer's role.
  Future<Either<Failure, CompanyModel>> getCompanyById(String companyId) async {
    try {
      final response = await _supabase
          .from(TableNames.companiesTable)
          .select()
          .eq('id', companyId)
          .single();
      final company = CompanyModel.fromJson(response);
      final myId = _supabase.auth.currentUser?.id;
      return Right(
        company.copyWith(myRole: company.ownerId == myId ? 'owner' : 'founder'),
      );
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to fetch company: $e'));
    }
  }

  /// Uploads a company logo to the `company-logos` bucket and returns its URL.
  Future<Either<Failure, String>> uploadCompanyLogo({
    required String filePath,
  }) async {
    try {
      final file = File(filePath);
      final fileName = filePath.split('/').last;
      final userId = _supabase.auth.currentUser?.id ?? 'anonymous';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = '$userId/${timestamp}_$fileName';

      await _supabase.storage.from(TableNames.companyLogosBucket).upload(
            storagePath,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      return Right(
        _supabase.storage
            .from(TableNames.companyLogosBucket)
            .getPublicUrl(storagePath),
      );
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to upload logo: $e'));
    }
  }

  // ── Founders ────────────────────────────────────────────────────────────────

  /// Creates the owner's own founder record (role=owner, status=active).
  Future<Either<Failure, FounderModel>> addOwnerFounder({
    required String companyId,
    required String ownerUserId,
    required String phone,
    String? fullName,
    required String designation,
  }) async {
    try {
      final response = await _supabase
          .from(TableNames.companyFoundersTable)
          .insert({
            'company_id': companyId,
            'user_id': ownerUserId,
            'phone': phone,
            'full_name': fullName,
            'designation': designation,
            'role': FounderRole.owner,
            'status': FounderStatus.active,
            'invited_by': ownerUserId,
            'responded_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      return Right(FounderModel.fromJson(response));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to register owner: $e'));
    }
  }

  /// Invites a founder by phone + designation. Auto-links an existing user.
  Future<Either<Failure, FounderModel>> inviteFounder({
    required String companyId,
    required String phone,
    required String designation,
  }) async {
    try {
      final response = await _supabase.rpc(
        'invite_founder',
        params: {
          'p_company_id': companyId,
          'p_phone': phone,
          'p_designation': designation,
        },
      );
      return Right(FounderModel.fromJson(_firstRow(response)));
    } catch (e) {
      return Left(ApiFailure(message: _humanizeError(e, phone)));
    }
  }

  /// All founders of a company (owner + invited). Caller must be a member.
  Future<Either<Failure, List<FounderModel>>> getCompanyFounders(
    String companyId,
  ) async {
    try {
      final response = await _supabase.rpc(
        'get_company_founders',
        params: {'p_company_id': companyId},
      );
      final founders = (response as List<dynamic>)
          .map((e) => FounderModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(founders);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to fetch founders: $e'));
    }
  }

  /// Removes a founder (owner only, enforced by RLS).
  Future<Either<Failure, Unit>> removeFounder(String founderId) async {
    try {
      await _supabase
          .from(TableNames.companyFoundersTable)
          .delete()
          .eq('id', founderId);
      return const Right(unit);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to remove founder: $e'));
    }
  }

  // ── Invitations ──────────────────────────────────────────────────────────────

  /// Pending founder invitations addressed to the current user.
  Future<Either<Failure, List<FounderInvitationModel>>>
      getMyInvitations() async {
    try {
      final response = await _supabase.rpc('get_my_founder_invitations');
      final invitations = (response as List<dynamic>)
          .map((e) => FounderInvitationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(invitations);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to fetch invitations: $e'));
    }
  }

  /// Approves or rejects an invitation. On approval the user becomes an active
  /// founder of the company.
  Future<Either<Failure, FounderModel>> respondToInvitation({
    required String invitationId,
    required bool accept,
  }) async {
    try {
      final response = await _supabase.rpc(
        'respond_to_founder_invitation',
        params: {'p_invitation_id': invitationId, 'p_accept': accept},
      );
      return Right(FounderModel.fromJson(_firstRow(response)));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to respond to invitation: $e'));
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// PostgREST returns a composite-returning function as a single object, but
  /// normalise to a Map either way so callers never have to care.
  Map<String, dynamic> _firstRow(dynamic response) {
    if (response is List) {
      return response.first as Map<String, dynamic>;
    }
    return response as Map<String, dynamic>;
  }

  /// Turns the raw unique-violation error into something readable.
  String _humanizeError(Object e, String phone) {
    final text = e.toString();
    if (text.contains('company_founders_company_id_phone_key') ||
        text.contains('duplicate key')) {
      return '$phone has already been invited to this company.';
    }
    return 'Failed to invite founder: $e';
  }
}
