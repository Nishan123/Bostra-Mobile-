import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/models/company_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/company/state/company_detail_state.dart';
import 'package:bostra/ui/company/view_model/company_detail_view_model.dart';
import 'package:bostra/ui/company/widgets/add_founder_sheet.dart';
import 'package:bostra/ui/company/widgets/campaigns_section.dart';
import 'package:bostra/ui/company/widgets/company_header.dart';
import 'package:bostra/ui/company/widgets/founders_section.dart';
import 'package:bostra/ui/start_campain/view_model/start_campaign_view_model.dart';
import 'package:bostra/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompanyDetailScreen extends ConsumerStatefulWidget {
  final CompanyModel company;
  const CompanyDetailScreen({super.key, required this.company});

  @override
  ConsumerState<CompanyDetailScreen> createState() =>
      _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends ConsumerState<CompanyDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(companyDetailViewModelProvider.notifier)
          .load(widget.company),
    );
  }

  void _invite() {
    AddFounderSheet.show(
      context,
      onAdd: (draft) {
        ref
            .read(companyDetailViewModelProvider.notifier)
            .inviteFounder(phone: draft.phone, designation: draft.designation);
      },
    );
  }

  Future<void> _confirmRemove(String founderId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove founder'),
        content: Text('Remove $name from this company?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Remove', style: TextStyle(color: AppColors.redColor)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref
          .read(companyDetailViewModelProvider.notifier)
          .removeFounder(founderId);
    }
  }

  void _launchCampaign(CompanyModel company) {
    ref.read(campaignViewModelProvider.notifier).startForCompany(company.id!);
    context.push('/start-campaign-1');
  }

  Future<void> _manageCampaign(CampaignModel campaign) async {
    await context.push('/manage-campaign', extra: campaign);
    if (mounted) {
      ref.read(companyDetailViewModelProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CompanyDetailState>(companyDetailViewModelProvider, (
      previous,
      next,
    ) {
      if (next.actionStatus == CompanyActionStatus.success) {
        CustomSnackBar.showSuccessSnackBar(
          context,
          next.actionMessage ?? 'Done.',
        );
        ref.read(companyDetailViewModelProvider.notifier).resetActionStatus();
      } else if (next.actionStatus == CompanyActionStatus.error) {
        CustomSnackBar.showErrorSnackBar(
          context,
          next.actionMessage ?? 'Action failed.',
        );
        ref.read(companyDetailViewModelProvider.notifier).resetActionStatus();
      }
    });

    final state = ref.watch(companyDetailViewModelProvider);
    final company = state.company ?? widget.company;

    return Scaffold(
      appBar: AppBar(title: const Text("Company Details")),
      body: SafeArea(child: _buildBody(state, company)),
    );
  }

  Widget _buildBody(CompanyDetailState state, CompanyModel company) {
    if (state.status == CompanyDetailStatus.loading ||
        state.status == CompanyDetailStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == CompanyDetailStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.circle_alert,
                size: 48,
                color: AppColors.redColor,
              ),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'Failed to load company.',
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyText2,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(companyDetailViewModelProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(companyDetailViewModelProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          CompanyHeader(company: company, founders: state.activeFounders),
          const SizedBox(height: 8),
          FoundersSection(
            state: state,
            onInvite: _invite,
            onRemove: _confirmRemove,
          ),
          const Divider(height: 32, thickness: 0.6, indent: 16, endIndent: 16),
          CampaignsSection(
            state: state,
            isVerified: company.isVerified,
            onLaunch: () => _launchCampaign(company),
            onManage: _manageCampaign,
          ),
        ],
      ),
    );
  }
}
