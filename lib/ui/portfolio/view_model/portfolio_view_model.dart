import 'package:bostra/controllers/gemini_controller.dart';
import 'package:bostra/controllers/investment_controller.dart';
import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/models/investment_model.dart';
import 'package:bostra/models/portfolio_models.dart';
import 'package:bostra/ui/portfolio/state/portfolio_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final portfolioViewModelProvider =
    NotifierProvider<PortfolioViewModel, PortfolioState>(
  PortfolioViewModel.new,
);

class PortfolioViewModel extends Notifier<PortfolioState> {
  late final InvestmentController _investmentController;
  late final GeminiController _geminiController;

  @override
  PortfolioState build() {
    _investmentController = ref.read(investmentControllerProvider);
    _geminiController = ref.read(geminiControllerProvider);
    return const PortfolioState();
  }

  /// Loads the user's investments and derives holdings, sector allocation and
  /// totals. Kicks off the AI summary once real holdings exist.
  Future<void> load() async {
    state = state.copyWith(status: PortfolioStatus.loading);

    final result = await _investmentController.getMyInvestments();

    await result.fold(
      (failure) async {
        state = state.copyWith(
          status: PortfolioStatus.error,
          errorMessage: failure.errorMessage,
        );
      },
      (investments) async {
        final holdings = _buildHoldings(investments);
        final totalInvested =
            holdings.fold<double>(0, (sum, h) => sum + h.invested);
        final totalImplied =
            holdings.fold<double>(0, (sum, h) => sum + h.impliedValue);
        final sectors = _buildSectors(holdings, totalInvested);

        state = state.copyWith(
          status: PortfolioStatus.success,
          holdings: holdings,
          sectors: sectors,
          totalInvested: totalInvested,
          totalImpliedValue: totalImplied,
          summaryStatus: SummaryStatus.idle,
        );

        if (holdings.isNotEmpty) {
          await generateSummary();
        }
      },
    );
  }

  /// Collapses many investments into one holding per campaign.
  List<PortfolioHolding> _buildHoldings(List<InvestmentModel> investments) {
    final byCampaign = <String, List<InvestmentModel>>{};
    for (final inv in investments) {
      if (inv.campaign == null) continue;
      byCampaign.putIfAbsent(inv.campaignId, () => []).add(inv);
    }

    final holdings = <PortfolioHolding>[];
    byCampaign.forEach((_, invs) {
      final campaign = invs.first.campaign!;
      final invested = invs.fold<double>(0, (sum, i) => sum + i.amount);
      final impliedValue = invested * (1 + _impliedReturnFactor(campaign));
      holdings.add(PortfolioHolding(
        campaign: campaign,
        invested: invested,
        impliedValue: impliedValue,
      ));
    });

    holdings.sort((a, b) => b.invested.compareTo(a.invested));
    return holdings;
  }

  /// Traction-based implied return factor from the campaign's funding momentum.
  /// 50% funded → 0, 100% → +0.25, 0% → -0.25. Overfunded campaigns trend
  /// higher (clamped). Not a market valuation — a transparent proxy.
  double _impliedReturnFactor(CampaignModel c) {
    if (c.targetAmount <= 0) return 0;
    final ratio = c.currentFunding / c.targetAmount;
    return (((ratio - 0.5) * 0.5).clamp(-0.5, 3.0)).toDouble();
  }

  List<SectorAllocation> _buildSectors(
    List<PortfolioHolding> holdings,
    double total,
  ) {
    if (total <= 0) return const [];

    final bySector = <String, double>{};
    for (final h in holdings) {
      bySector.update(
        h.sector,
        (value) => value + h.invested,
        ifAbsent: () => h.invested,
      );
    }

    final sectors = bySector.entries
        .map((e) => SectorAllocation(
              label: e.key,
              amount: e.value,
              fraction: e.value / total,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return sectors;
  }

  /// Asks Gemini to summarise the current portfolio. [detailed] powers the
  /// "Ask More" button with a longer, analytical prompt.
  Future<void> generateSummary({bool detailed = false}) async {
    if (state.holdings.isEmpty) return;

    state = state.copyWith(summaryStatus: SummaryStatus.loading);

    final result = await _geminiController.generateText(
      _buildPrompt(detailed: detailed),
    );

    result.fold(
      (failure) => state = state.copyWith(
        summaryStatus: SummaryStatus.error,
        summaryError: failure.errorMessage,
      ),
      (text) => state = state.copyWith(
        summaryStatus: SummaryStatus.success,
        aiSummary: text,
      ),
    );
  }

  String _buildPrompt({required bool detailed}) {
    final buffer = StringBuffer()
      ..writeln(
        "You are a financial assistant summarising a user's startup "
        'investment portfolio in the Bostra app. Amounts are in Nepali '
        'Rupees (Rs).',
      )
      ..writeln(
        'Total invested: Rs ${state.totalInvested.toStringAsFixed(0)} across '
        '${state.holdings.length} startups in ${state.sectors.length} '
        'sector(s).',
      )
      ..writeln('Holdings:');

    for (final h in state.holdings) {
      buffer.writeln(
        '- ${h.startupName} (${h.sector}): invested '
        'Rs ${h.invested.toStringAsFixed(0)}, campaign '
        '${(h.campaign.fundingProgress * 100).toStringAsFixed(0)}% funded.',
      );
    }

    buffer.writeln('Sector allocation:');
    for (final s in state.sectors) {
      buffer.writeln('- ${s.label}: ${s.percent}%');
    }

    if (detailed) {
      buffer.writeln(
        '\nWrite a detailed 2-3 paragraph analysis covering diversification, '
        'concentration risk, sector exposure, and one concrete, actionable '
        'suggestion. Plain language, friendly, specific. No preamble, no '
        'disclaimers, no markdown headings.',
      );
    } else {
      buffer.writeln(
        '\nWrite a concise 3-4 sentence summary: how diversified the portfolio '
        'is, where the money is concentrated, and the overall posture. Plain '
        'language, friendly. No preamble, no disclaimers, no markdown.',
      );
    }

    return buffer.toString();
  }
}
