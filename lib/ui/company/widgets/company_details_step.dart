import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/company/view_model/register_company_view_model.dart';
import 'package:bostra/ui/company/widgets/company_logo_picker.dart';
import 'package:bostra/ui/company/widgets/designation_dropdown.dart';
import 'package:bostra/ui/start_campain/widgets/campaign_textfield.dart';
import 'package:bostra/ui/start_campain/widgets/industry_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Step 1 of company registration: company details. Owns its own text
/// controllers and writes every change straight into the register view model,
/// which is the source of truth the parent validates against.
class CompanyDetailsStep extends ConsumerStatefulWidget {
  const CompanyDetailsStep({super.key});

  @override
  ConsumerState<CompanyDetailsStep> createState() => _CompanyDetailsStepState();
}

class _CompanyDetailsStepState extends ConsumerState<CompanyDetailsStep> {
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _registrationController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _websiteController = TextEditingController();
  final _emailController = TextEditingController();

  String? _industry;
  String? _ownerDesignation;

  RegisterCompanyViewModel get _vm =>
      ref.read(registerCompanyViewModelProvider.notifier);

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _descriptionController.dispose();
    _registrationController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _websiteController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget _label(String text) => Text(
        text,
        style: AppTextStyle.bodyText2.copyWith(
          color: AppColors.blackColor.withAlpha(180),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          CompanyLogoPicker(onChanged: _vm.setLogoPath),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Company logo (optional)',
              style: AppTextStyle.bodyText3,
            ),
          ),
          const SizedBox(height: 16),
          CampaignTextfield(
            label: 'Company name *',
            hintText: 'e.g. Bostra Labs Pvt. Ltd.',
            controller: _nameController,
            onChanged: (v) => _vm.updateName(v.trim()),
          ),
          const SizedBox(height: 14),
          CampaignTextfield(
            label: 'Tagline',
            hintText: 'One line about your company',
            controller: _taglineController,
            onChanged: (v) => _vm.updateTagline(v.trim()),
          ),
          const SizedBox(height: 14),
          CampaignTextfield(
            label: 'Description',
            hintText: 'What does your company do?',
            controller: _descriptionController,
            maxLines: 4,
            onChanged: (v) => _vm.updateDescription(v.trim()),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Industry'),
                const SizedBox(height: 6),
                IndustryDropdown(
                  selectedIndustry: _industry,
                  onChanged: (v) {
                    setState(() => _industry = v);
                    if (v != null) _vm.updateIndustry(v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          CampaignTextfield(
            label: 'Registration number',
            hintText: 'Company registration / PAN number',
            controller: _registrationController,
            onChanged: (v) => _vm.updateRegistrationNumber(v.trim()),
          ),
          const SizedBox(height: 14),
          CampaignTextfield(
            label: 'City',
            hintText: 'e.g. Kathmandu',
            controller: _cityController,
            onChanged: (v) => _vm.updateCity(v.trim()),
          ),
          const SizedBox(height: 14),
          CampaignTextfield(
            label: 'Country',
            hintText: 'e.g. Nepal',
            controller: _countryController,
            onChanged: (v) => _vm.updateCountry(v.trim()),
          ),
          const SizedBox(height: 14),
          CampaignTextfield(
            label: 'Website',
            hintText: 'https://...',
            controller: _websiteController,
            keyboardType: TextInputType.url,
            onChanged: (v) => _vm.updateWebsite(v.trim()),
          ),
          const SizedBox(height: 14),
          CampaignTextfield(
            label: 'Company email',
            hintText: 'hello@company.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => _vm.updateEmail(v.trim()),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Your role in the company *'),
                const SizedBox(height: 6),
                DesignationDropdown(
                  selected: _ownerDesignation,
                  hint: 'Select your designation',
                  onChanged: (v) {
                    setState(() => _ownerDesignation = v);
                    if (v != null) _vm.setOwnerDesignation(v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
