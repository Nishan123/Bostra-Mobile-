import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:bostra/controllers/auth_controller.dart';
import 'package:bostra/controllers/user_controller.dart';
import 'package:bostra/ui/auth/state/auth_state.dart';
import 'package:bostra/ui/profile/view_model/profile_view_model.dart';
import 'package:bostra/ui/investment/view_model/investment_tab_view_model.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);

class AuthViewModel extends Notifier<AuthState> {
  late final AuthController _authController;
  late final UserController _userController;

  @override
  AuthState build() {
    _authController = ref.read(authControllerProvider);
    _userController = ref.read(userControllerProvider);
    return const AuthState();
  }

  /// Sends an OTP to the given phone number.
  Future<void> sendOtp({
    required String countryCode,
    required String phone,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final fullPhoneNo = await _authController.sendOtp(
        countryCode: countryCode,
        phone: phone,
      );
      state = state.copyWith(
        status: AuthStatus.success,
        phoneNumber: fullPhoneNo,
      );
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: "An unexpected error occurred: ${e.toString()}",
      );
    }
  }

  /// Verifies the OTP token then checks if the user exists in the database.
  ///
  /// Returns the GoRouter **route name** to navigate to:
  /// - `'userDetails'`  → new user (not found in users table)
  /// - `'main'`         → existing user
  /// - `null`           → error (state.errorMessage will be set)
  Future<String?> verifyOtp(String otp) async {
    final phoneNo = state.phoneNumber;
    if (phoneNo == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: "Phone number not found. Please try again.",
      );
      return null;
    }

    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      // Step 1: Verify OTP with Supabase Auth
      await _authController.verifyOtp(phoneNo: phoneNo, otp: otp);

      // Step 2: Check if a user row already exists in our users table
      final result = await _userController.checkUserExists(phoneNo);

      return result.fold(
        (failure) {
          // If the check itself fails (e.g. table not yet created),
          // treat the user as new so they can complete onboarding.
          state = state.copyWith(status: AuthStatus.initial);
          return 'userDetails';
        },
        (exists) {
          state = state.copyWith(status: AuthStatus.initial);
          return exists ? 'main' : 'userDetails';
        },
      );
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: "An unexpected error occurred: ${e.toString()}",
      );
      return null;
    }
  }

  /// Logs out the current user.
  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authController.signOut();
      
      // Explicitly invalidate all user-related view models on logout to wipe cache
      ref.invalidate(profileViewModelProvider);
      ref.invalidate(investmentTabViewModelProvider);
      
      state = const AuthState();
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: "An unexpected error occurred: ${e.toString()}",
      );
    }
  }

  /// Resets the status to initial and clears the error message.
  void resetStatus() {
    state = state.copyWith(status: AuthStatus.initial, errorMessage: null);
  }
}
