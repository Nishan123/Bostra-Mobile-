import 'package:bostra/constants/assets_path.dart';
import 'package:bostra/constants/country_picker_constants.dart';
import 'package:bostra/models/country.dart';
import 'package:bostra/ui/auth/state/auth_state.dart';
import 'package:bostra/ui/auth/view_models/auth_view_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/auth/widgets/country_picker_sheet.dart';
import 'package:bostra/ui/auth/widgets/phone_field.dart';
import 'package:bostra/widgets/custom_snackbar.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:bostra/widgets/privacy_policy_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  Country pickedCountry = CountryPickerConstants.availableCountries[0];
  bool isAgreed = true;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.success) {
        ref.read(authViewModelProvider.notifier).resetStatus();
        context.pushNamed("otp");
      } else if (next.status == AuthStatus.error) {
        final message = next.errorMessage ?? "Failed to send OTP";
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
              SizedBox(height: height * 0.06),

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

              SizedBox(height: height * 0.08),

              // Heading
              Text(
                "Enter your phone number.",
                style: AppTextStyle.h1,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: 8),
              // Phone Field
              PhoneField(
                controller: phoneController,
                pickerTab: () {
                  CountryPickerSheet.showAvailableCountry(
                    context: context,
                    pickedCountry: pickedCountry,
                    onCountrySelected: (country) {
                      setState(() {
                        pickedCountry = country;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
                pickedCountry: pickedCountry,
              ),
              SizedBox(height: 8),
              // explanatory text
              Text(
                "After confirming your phone number, Bostra will provide you with an OTP. There are no carrier fees required.",
                style: AppTextStyle.normalText.copyWith(
                  color: AppColors.black10,
                ),
              ),
              // push button to the bottom while allowing the content to shrink/grow
              const Expanded(child: SizedBox()),
              PrivacyPolicyCheckbox(
                value: isAgreed,
                onChanged: (value) {
                  setState(() {
                    isAgreed = value ?? false;
                  });
                },
              ),
              Padding(
                padding: EdgeInsets.only(bottom: mq.viewPadding.bottom + 4),
                child: PrimaryButton(
                  text: "Next",
                  isLoading: authState.status == AuthStatus.loading,
                  onTap: () {
                    if (!isAgreed) {
                      CustomSnackBar.showErrorSnackBar(
                        context,
                        "You must agree to the privacy policy & legal terms.",
                      );
                      return;
                    }

                    final phone = phoneController.text.trim();
                    if (phone.isEmpty) {
                      CustomSnackBar.showErrorSnackBar(
                        context,
                        "Please enter your phone number.",
                      );
                      return;
                    }

                    ref
                        .read(authViewModelProvider.notifier)
                        .sendOtp(
                          countryCode: pickedCountry.phoneCode,
                          phone: phone,
                        );
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
