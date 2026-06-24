import 'dart:io';

import 'package:bostra/constants/table_names.dart';
import 'package:bostra/failure/failure.dart';
import 'package:bostra/models/user_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userControllerProvider = Provider((ref) {
  return UserController();
});

class UserController {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Returns true if a user with the given phone number already exists.
  Future<Either<Failure, bool>> checkUserExists(String phone) async {
    try {
      final response = await _supabase
          .from(TableNames.usersTable)
          .select('id')
          .eq('phone', phone)
          .maybeSingle();

      return Right(response != null);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to check user existence: $e'));
    }
  }

  /// Creates a new user row linked to the current Supabase Auth user.
  Future<Either<Failure, UserModel>> createUser(String phone) async {
    try {
      final authUserId = Supabase.instance.client.auth.currentUser?.id;
      if (authUserId == null) {
        return Left(ApiFailure(message: 'No authenticated user found.'));
      }
      final response = await _supabase
          .from(TableNames.usersTable)
          .insert({'id': authUserId, 'phone': phone})
          .select()
          .single();

      return Right(UserModel.fromJson(response));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to create user: $e'));
    }
  }

  /// Updates personal details (full name, DOB, address, profile_pic_url) for an existing user.
  Future<Either<Failure, UserModel>> updateUserDetails({
    required String userId,
    required String fullName,
    required String dob,
    required String address,
    String? profilePicUrl,
  }) async {
    try {
      final response = await _supabase
          .from(TableNames.usersTable)
          .update({
            'full_name': fullName,
            'dob': dob,
            'address': address,
            'profile_pic_url':? profilePicUrl,
          })
          .eq('id', userId)
          .select()
          .single();

      return Right(UserModel.fromJson(response));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to update user details: $e'));
    }
  }

  /// Uploads a document file to Supabase Storage and returns its public URL.
  Future<Either<Failure, String>> uploadDocument({
    required String userId,
    required File file,
    required String fileName,
  }) async {
    try {
      final path = '$userId/$fileName';
      final bytes = await file.readAsBytes();
      final fileExt = fileName.split('.').last;

      await _supabase.storage
          .from(TableNames.userDocumentsBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );

      final publicUrl = _supabase.storage
          .from(TableNames.userDocumentsBucket)
          .getPublicUrl(path);

      return Right(publicUrl);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to upload document: $e'));
    }
  }

  /// Saves a document URL back to the users table.
  Future<Either<Failure, void>> saveDocumentUrl({
    required String userId,
    required String column,
    required String url,
  }) async {
    try {
      await _supabase
          .from(TableNames.usersTable)
          .update({column: url})
          .eq('id', userId);

      return const Right(null);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to save document URL: $e'));
    }
  }

  /// Fetches a user record by phone number. Returns null if not found.
  Future<Either<Failure, UserModel?>> getUserByPhone(String phone) async {
    try {
      final response = await _supabase
          .from(TableNames.usersTable)
          .select()
          .eq('phone', phone)
          .maybeSingle();

      if (response == null) return const Right(null);
      return Right(UserModel.fromJson(response));
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to fetch user: $e'));
    }
  }

  /// Fetches public profile fields (id, name, pic) for multiple users.
  ///
  /// Goes through the `get_public_profiles` RPC instead of selecting from the
  /// users table directly — RLS normally blocks reading *other* users' rows,
  /// which is why backer avatars came back empty. The RPC runs SECURITY
  /// DEFINER and returns only safe fields, so no PII (phone, address, IDs) is
  /// exposed. `phone` is left blank since callers only need id/name/pic.
  Future<Either<Failure, List<UserModel>>> getUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return const Right([]);
    try {
      final response = await _supabase.rpc(
        'get_public_profiles',
        params: {'p_ids': ids},
      );

      final list = (response as List<dynamic>).map((e) {
        final map = e as Map<String, dynamic>;
        return UserModel(
          id: map['id'] as String,
          phone: '',
          fullName: map['full_name'] as String?,
          profilePicUrl: map['profile_pic_url'] as String?,
        );
      }).toList();
      return Right(list);
    } catch (e) {
      return Left(ApiFailure(message: 'Failed to fetch users: $e'));
    }
  }
}

final campaignInvestorsProvider = FutureProvider.family<List<UserModel>, List<String>>((ref, ids) async {
  if (ids.isEmpty) return const [];
  final userController = ref.watch(userControllerProvider);
  final result = await userController.getUsersByIds(ids);
  return result.fold(
    (failure) => throw Exception(failure.errorMessage),
    (users) => users,
  );
});

