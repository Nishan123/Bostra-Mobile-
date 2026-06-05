import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:bostra/controllers/auth_controller.dart';
import 'package:bostra/ui/auth/state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);

class AuthViewModel extends Notifier<AuthState> {
  late final AuthController _authController;

  @override
  AuthState build() {
    _authController = ref.read(authControllerProvider);
    return AuthState();
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

  /// Verifies the OTP token against the stored phone number.
  Future<void> verifyOtp(String otp) async {
    final phoneNo = state.phoneNumber;
    if (phoneNo == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: "Phone number not found. Please try again.",
      );
      return;
    }
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authController.verifyOtp(phoneNo: phoneNo, otp: otp);
      state = state.copyWith(status: AuthStatus.success);
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: "An unexpected error occurred: ${e.toString()}",
      );
    }
  }

  /// Logs out the current user.
  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _authController.signOut();
      state = AuthState();
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
