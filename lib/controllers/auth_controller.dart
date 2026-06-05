import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authControllerProvider = Provider((ref) {
  return AuthController();
});

class AuthController {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> sendOtp({
    required String countryCode,
    required String phone,
  }) async {
    final fullPhoneNo = '$countryCode$phone';
    await _supabase.auth.signInWithOtp(phone: fullPhoneNo);
    return fullPhoneNo;
  }

  Future<void> verifyOtp({required String phoneNo, required String otp}) async {
    await _supabase.auth.verifyOTP(
      type: OtpType.sms,
      phone: phoneNo,
      token: otp,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
