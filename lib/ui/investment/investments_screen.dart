import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/investment/state/investment_tab_state.dart';
import 'package:bostra/ui/investment/view_model/investment_tab_view_model.dart';
import 'package:bostra/ui/investment/widdgets/my_investment_card.dart';
import 'package:bostra/ui/investment/widdgets/my_startup_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvestmentsScreen extends ConsumerStatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  ConsumerState<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends ConsumerState<InvestmentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(investmentTabViewModelProvider.notifier).fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(investmentTabViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Investments & Startups"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 0.6,
                  color: AppColors.blackColor.withAlpha(80),
                ),
              ),
            ),
          ),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              labelStyle: AppTextStyle.bodyText1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
              unselectedLabelStyle: AppTextStyle.bodyText1.copyWith(
                fontWeight: FontWeight.w100,
              ),
              indicatorPadding: const EdgeInsets.only(bottom: 4),
              indicator: UnderlineTabIndicator(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(width: 4, color: AppColors.primaryColor),
              ),
              tabs: const [
                Tab(text: "Investments"),
                Tab(text: "My Startups"),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.status == InvestmentTabStatus.loading &&
                      state.investments.isEmpty &&
                      state.myCampaigns.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  }

                  if (state.status == InvestmentTabStatus.error &&
                      state.investments.isEmpty &&
                      state.myCampaigns.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.errorMessage ?? "An error occurred",
                              style: AppTextStyle.bodyText1.copyWith(color: AppColors.redColor),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(investmentTabViewModelProvider.notifier).fetchData();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                              ),
                              child: const Text("Retry", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return TabBarView(
                    children: [
                      // Investments Tab
                      RefreshIndicator(
                        onRefresh: () => ref
                            .read(investmentTabViewModelProvider.notifier)
                            .fetchData(),
                        color: AppColors.primaryColor,
                        child: state.investments.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    child: Center(
                                      child: Text(
                                        "No investments yet.",
                                        style: AppTextStyle.bodyText1,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: state.investments.length,
                                itemBuilder: (context, index) {
                                  return MyInvestmentCard(
                                    investment: state.investments[index],
                                  );
                                },
                              ),
                      ),

                      // My Startups Tab
                      RefreshIndicator(
                        onRefresh: () => ref
                            .read(investmentTabViewModelProvider.notifier)
                            .fetchData(),
                        color: AppColors.primaryColor,
                        child: state.myCampaigns.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    child: Center(
                                      child: Text(
                                        "No startups created.",
                                        style: AppTextStyle.bodyText1,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                itemCount: state.myCampaigns.length,
                                itemBuilder: (context, index) {
                                  return MyStartupCard(
                                    campaign: state.myCampaigns[index],
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
