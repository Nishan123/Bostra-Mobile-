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

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.success) {
        ref.read(authViewModelProvider.notifier).resetStatus();
        context.goNamed("main");
      } else if (next.status == AuthStatus.error) {
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
              SizedBox(height: 8),
              // OTP Filed
              OtpField(controller: otpController),
              SizedBox(height: 8),
              // explanatory text
              Text(
                "We’ve sent an OTP to ${authState.phoneNumber ?? 'your number'}. Enter it to verify\nyour number.",
                style: AppTextStyle.normalText.copyWith(
                  color: AppColors.black10,
                ),
              ),
              SizedBox(height: height * 0.03),
              Row(
                children: [
                  Text("Didn't received OTP code?  "),
                  Text("Resend OTP", style: AppTextStyle.buttonTextStyle),
                ],
              ),
              // push button to the bottom while allowing the content to shrink/grow
              const Expanded(child: SizedBox()),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("OTP expires in ${otpExperiesIn.toString()} seconds"),
                ],
              ),

              Padding(
                padding: EdgeInsets.only(
                  bottom: mq.viewPadding.bottom + 16,
                  top: 12,
                ),
                child: PrimaryButton(
                  text: "Next",
                  isLoading: authState.status == AuthStatus.loading,
                  onTap: () {
                    final otp = otpController.text.trim();
                    if (otp.length < 6) {
                      CustomSnackBar.showErrorSnackBar(
                        context,
                        "Please enter the complete 6-digit OTP code.",
                      );
                      return;
                    }
                    if (otpExperiesIn == 0) {
                      CustomSnackBar.showErrorSnackBar(
                        context,
                        "OTP code has expired",
                      );
                      return;
                    }

                    ref.read(authViewModelProvider.notifier).verifyOtp(otp);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
