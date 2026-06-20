import 'package:bostra/constants/assets_path.dart';
import 'package:bostra/controllers/user_controller.dart';
import 'package:bostra/routes/app_routes.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/auth/state/user_details_state.dart';
import 'package:bostra/ui/auth/view_models/user_details_view_model.dart';
import 'package:bostra/ui/auth/widgets/document_upload_step.dart';
import 'package:bostra/ui/auth/widgets/personal_info_step.dart';
import 'package:bostra/widgets/custom_snackbar.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDetailsScreen extends ConsumerStatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  ConsumerState<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends ConsumerState<UserDetailsScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dobController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _handleNext() async {
    final state = ref.read(userDetailsViewModelProvider);
    final notifier = ref.read(userDetailsViewModelProvider.notifier);

    if (state.currentStep == 0) {
      // Validate Step 1
      if (_nameController.text.trim().isEmpty) {
        CustomSnackBar.showErrorSnackBar(context, 'Please enter your full name.');
        return;
      }
      if (_dobController.text.trim().isEmpty) {
        CustomSnackBar.showErrorSnackBar(context, 'Please select your date of birth.');
        return;
      }
      if (_addressController.text.trim().isEmpty) {
        CustomSnackBar.showErrorSnackBar(context, 'Please enter your permanent address.');
        return;
      }

      // Get current user ID — after OTP, a Supabase Auth user exists
      final authUser = Supabase.instance.client.auth.currentUser;
      if (authUser == null) {
        CustomSnackBar.showErrorSnackBar(context, 'Session expired. Please log in again.');
        return;
      }

      // First, ensure the user row exists in our users table
      final userController = ref.read(userControllerProvider);
      final phone = authUser.phone ?? '';
      final checkResult = await userController.checkUserExists(phone);
      bool rowExists = false;
      checkResult.fold((_) {}, (exists) => rowExists = exists);

      if (!rowExists) {
        final createResult = await userController.createUser(phone);
        bool created = false;
        createResult.fold(
          (failure) {
            CustomSnackBar.showErrorSnackBar(context, failure.errorMessage);
          },
          (_) => created = true,
        );
        if (!created) return;
      }

      // Fetch the user to get the DB id
      final userResult = await userController.getUserByPhone(phone);
      String? userId;
      userResult.fold(
        (failure) {
          CustomSnackBar.showErrorSnackBar(context, failure.errorMessage);
        },
        (user) => userId = user?.id,
      );
      if (userId == null) return;

      final success = await notifier.submitPersonalDetails(
        userId: userId!,
        fullName: _nameController.text.trim(),
        dob: _dobController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (success) {
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      } else {
        final errMsg = ref.read(userDetailsViewModelProvider).errorMessage;
        if (mounted) {
          CustomSnackBar.showErrorSnackBar(
              context, errMsg ?? 'Failed to save details.');
        }
      }
    } else {
      // Step 2 — submit documents
      final authUser = Supabase.instance.client.auth.currentUser;
      if (authUser == null) {
        CustomSnackBar.showErrorSnackBar(context, 'Session expired. Please log in again.');
        return;
      }

      final userController = ref.read(userControllerProvider);
      final phone = authUser.phone ?? '';
      final userResult = await userController.getUserByPhone(phone);
      String? userId;
      userResult.fold(
        (failure) {
          CustomSnackBar.showErrorSnackBar(context, failure.errorMessage);
        },
        (user) => userId = user?.id,
      );
      if (userId == null) return;

      final success = await notifier.submitDocuments(userId!);
      if (success && mounted) {
        // Refresh router's onboarding cache so it knows onboarding is done,
        // then navigate. Without this, a hot-reload would still see onboarding
        // as incomplete and redirect back to /user-details.
        await AppRoutes.refreshOnboardingStatus();
        if (mounted) context.goNamed('main');
      } else if (!success && mounted) {
        final errMsg = ref.read(userDetailsViewModelProvider).errorMessage;
        CustomSnackBar.showErrorSnackBar(
            context, errMsg ?? 'Failed to upload documents.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userDetailsViewModelProvider);
    final mq = MediaQuery.of(context);
    final height = mq.size.height;
    final isLoading = state.status == UserDetailsStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.05),

              // App logo — centered
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    '${AssetsPath.svgPath}logo_with_slogan.svg',
                    height: 60,
                  ),
                ],
              ),

              SizedBox(height: height * 0.05),

              // Page content — non-scrollable step views
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Step 1
                    SingleChildScrollView(
                      child: PersonalInfoStep(
                        nameController: _nameController,
                        dobController: _dobController,
                        addressController: _addressController,
                        onDobTap: _showDatePicker,
                      ),
                    ),

                    // Step 2
                    const SingleChildScrollView(
                      child: DocumentUploadStep(),
                    ),
                  ],
                ),
              ),

              // Step indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyle.bodyText1.copyWith(
                      color: AppColors.blackColor,
                    ),
                    children: [
                      const TextSpan(text: 'Step '),
                      TextSpan(
                        text: '${state.currentStep + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: ' of 2'),
                    ],
                  ),
                ),
              ),

              // Next button
              Padding(
                padding: EdgeInsets.only(
                  bottom: mq.viewPadding.bottom + 16,
                  top: 4,
                ),
                child: PrimaryButton(
                  text: 'Next',
                  isLoading: isLoading,
                  onTap: _handleNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
