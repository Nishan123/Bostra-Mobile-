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

  /// Updates personal details (full name, DOB, address) for an existing user.
  Future<Either<Failure, UserModel>> updateUserDetails({
    required String userId,
    required String fullName,
    required String dob,
    required String address,
  }) async {
    try {
      final response = await _supabase
          .from(TableNames.usersTable)
          .update({
            'full_name': fullName,
            'dob': dob,
            'address': address,
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
}
