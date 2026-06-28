import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/portfolio/state/portfolio_state.dart';
import 'package:bostra/ui/portfolio/view_model/portfolio_view_model.dart';
import 'package:bostra/ui/portfolio/widgets/invested_company_tile.dart';
import 'package:bostra/ui/portfolio/widgets/portfolio_chat_sheet.dart';
import 'package:bostra/ui/portfolio/widgets/portfolio_pie_chart.dart';
import 'package:bostra/ui/portfolio/widgets/summary_paragraph.dart';
import 'package:bostra/ui/portfolio/widgets/totals_header.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:bostra/widgets/widget_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  @override
  void initState() {
    super.initState();
    // Load once; the provider keeps state across tab switches so we don't
    // re-hit Gemini every time the tab is opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final vm = ref.read(portfolioViewModelProvider.notifier);
      if (ref.read(portfolioViewModelProvider).status ==
          PortfolioStatus.initial) {
        vm.load();
      }
    });
  }

  void _reload() => ref.read(portfolioViewModelProvider.notifier).load();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(portfolioViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Portfolio'),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.6,
                color: AppColors.blackColor.withAlpha(80),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(portfolioViewModelProvider.notifier).load(),
          child: _buildBody(state),
        ),
      ),
    );
  }

  Widget _buildBody(PortfolioState state) {
    switch (state.status) {
      case PortfolioStatus.initial:
      case PortfolioStatus.loading:
        return const _CenteredScroll(
          child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: CircularProgressIndicator(),
          ),
        );
      case PortfolioStatus.error:
        return _CenteredScroll(
          child: _ErrorView(
            message: state.errorMessage ?? 'Something went wrong.',
            onRetry: _reload,
          ),
        );
      case PortfolioStatus.success:
        if (state.isEmpty) {
          return const _CenteredScroll(child: _EmptyView());
        }
        return _content(state);
    }
  }

  Widget _content(PortfolioState state) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          WidgetTitle(text: "Total Investments"),
          TotalsHeader(state: state),

          const SizedBox(height: 18),
          const WidgetTitle(text: 'Invested Companies'),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.holdings.length,
            itemBuilder: (_, i) =>
                InvestedCompanyTile(holding: state.holdings[i]),
          ),

          const SizedBox(height: 18),
          const WidgetTitle(text: 'Investment Diversity'),
          PortfolioPieChart(sectors: state.sectors),

          const SizedBox(height: 18),
          const WidgetTitle(text: 'AI Summary'),
          _SummarySection(state: state),

          PrimaryButton(
            margin: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 24,
              bottom: 24,
            ),
            text: 'Ask More',
            onTap: () => PortfolioChatSheet.show(context),
          ),
        ],
      ),
    );
  }
}


/// Renders the AI summary across its loading / success / error states.
class _SummarySection extends StatelessWidget {
  final PortfolioState state;
  const _SummarySection({required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state.summaryStatus) {
      case SummaryStatus.idle:
      case SummaryStatus.loading:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Text('Generating AI summary…', style: AppTextStyle.bodyText2),
            ],
          ),
        );
      case SummaryStatus.error:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.blackColor.withAlpha(120),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.summaryError ?? 'Could not generate a summary.',
                  style: AppTextStyle.bodyText2,
                ),
              ),
            ],
          ),
        );
      case SummaryStatus.success:
        return SummaryParagraph(text: state.aiSummary ?? '');
    }
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: AppColors.blackColor.withAlpha(60),
          ),
          const SizedBox(height: 16),
          Text('No investments yet', style: AppTextStyle.h3),
          const SizedBox(height: 8),
          Text(
            'Back a startup and it’ll show up here with your sector mix and an AI summary.',
            textAlign: TextAlign.center,
            style: AppTextStyle.bodyText2,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 44, color: AppColors.redColor),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyle.bodyText2,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A scrollable wrapper so [RefreshIndicator] still works on the
/// loading / empty / error states.
class _CenteredScroll extends StatelessWidget {
  final Widget child;
  const _CenteredScroll({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}
