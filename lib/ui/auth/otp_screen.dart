import 'package:bostra/constants/assets_path.dart';
import 'package:bostra/ui/auth/state/auth_state.dart';
import 'package:bostra/ui/auth/view_models/auth_view_model.dart';
import 'package:bostra/ui/auth/widgets/otp_field.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/widgets/custom_snackbar.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final otpController = TextEditingController();
  int otpExperiesIn = 60;

  void beginCountdown() async {
    while (otpExperiesIn > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        otpExperiesIn--;
      });
    }
  }

  @override
  void initState() {
    beginCountdown();
    super.initState();
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final otp = otpController.text.trim();

    if (otp.length < 6) {
      CustomSnackBar.showErrorSnackBar(
        context,
        "Please enter the complete 6-digit OTP code.",
      );
      return;
    }
    if (otpExperiesIn == 0) {
      CustomSnackBar.showErrorSnackBar(context, "OTP code has expired");
      return;
    }

    // verifyOtp returns the route name to navigate to, or null on error.
    final routeName =
        await ref.read(authViewModelProvider.notifier).verifyOtp(otp);

    if (!mounted) return;

    if (routeName != null) {
      context.goNamed(routeName);
    } else {
      // Error is already set in state; ref.listen below will show the snackbar.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only listen for errors — navigation is handled directly in _handleVerify.
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        final message = next.errorMessage ?? "Verification failed";
        CustomSnackBar.showErrorSnackBar(context, message);
        ref.read(authViewModelProvider.notifier).resetStatus();
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final mq = MediaQuery.of(context);
    final height = mq.size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.08),

              // App logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "${AssetsPath.svgPath}logo_with_slogan.svg",
                    height: 60,
                  ),
                ],
              ),

              SizedBox(height: height * 0.09),

              // Heading
              Text(
                "Verify your OTP.",
                style: AppTextStyle.h1,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              // OTP Field
              OtpField(controller: otpController),
              const SizedBox(height: 8),
              // Explanatory text
              Text(
                "We've sent an OTP to ${authState.phoneNumber ?? 'your number'}. Enter it to verify\nyour number.",
                style: AppTextStyle.normalText.copyWith(
                  color: AppColors.black10,
                ),
              ),
              SizedBox(height: height * 0.03),
              Row(
                children: [
                  const Text("Didn't received OTP code?  "),
                  Text("Resend OTP", style: AppTextStyle.buttonTextStyle),
                ],
              ),
              // Push button to the bottom
              const Expanded(child: SizedBox()),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("OTP expires in ${otpExperiesIn.toString()} seconds"),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                  top: 12,
                ),
                child: PrimaryButton(
                  text: "Next",
                  isLoading: authState.status == AuthStatus.loading,
                  onTap: _handleVerify,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
