import 'package:bostra/models/company_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/company/state/my_companies_state.dart';
import 'package:bostra/ui/company/view_model/my_companies_view_model.dart';
import 'package:bostra/ui/company/widgets/company_card.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyCompaniesScreen extends ConsumerStatefulWidget {
  const MyCompaniesScreen({super.key});

  @override
  ConsumerState<MyCompaniesScreen> createState() => _MyCompaniesScreenState();
}

class _MyCompaniesScreenState extends ConsumerState<MyCompaniesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(myCompaniesViewModelProvider.notifier).fetchMyCompanies(),
    );
  }

  Future<void> _openRegister() async {
    await context.push('/register-company');
    if (mounted) {
      ref.read(myCompaniesViewModelProvider.notifier).fetchMyCompanies();
    }
  }

  Future<void> _openCompany(CompanyModel company) async {
    await context.push('/company-detail', extra: company);
    if (mounted) {
      ref.read(myCompaniesViewModelProvider.notifier).fetchMyCompanies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myCompaniesViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Companies'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 0.6,
            color: AppColors.blackColor.withAlpha(80),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody(state)),
            if (state.status == MyCompaniesStatus.success &&
                state.companies.isNotEmpty)
              state.ownsCompany
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.info,
                              size: 14,
                              color: AppColors.blackColor.withAlpha(120)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'You can register only one company per account.',
                              style: AppTextStyle.bodyText3,
                            ),
                          ),
                        ],
                      ),
                    )
                  : PrimaryButton(
                      margin: const EdgeInsets.all(16),
                      text: 'Register a company',
                      onTap: _openRegister,
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(MyCompaniesState state) {
    switch (state.status) {
      case MyCompaniesStatus.initial:
      case MyCompaniesStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case MyCompaniesStatus.error:
        return _CenteredMessage(
          icon: LucideIcons.circle_alert,
          message: state.errorMessage ?? 'Something went wrong.',
          actionLabel: 'Retry',
          onAction: () => ref
              .read(myCompaniesViewModelProvider.notifier)
              .fetchMyCompanies(),
        );

      case MyCompaniesStatus.success:
        if (state.companies.isEmpty) {
          return _EmptyState(onRegister: _openRegister);
        }
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(myCompaniesViewModelProvider.notifier).fetchMyCompanies(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.companies.length,
            itemBuilder: (context, index) {
              final company = state.companies[index];
              return CompanyCard(
                company: company,
                onTap: () => _openCompany(company),
              );
            },
          ),
        );
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRegister;
  const _EmptyState({required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.building_2,
                size: 56, color: AppColors.primaryColor.withAlpha(140)),
            const SizedBox(height: 16),
            Text('No companies yet', style: AppTextStyle.h3),
            const SizedBox(height: 8),
            Text(
              'Register your company first — campaigns are launched under a company you own or co-found.',
              textAlign: TextAlign.center,
              style: AppTextStyle.bodyText2,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Register a company',
              onTap: onRegister,
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _CenteredMessage({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.redColor),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center, style: AppTextStyle.bodyText1),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
