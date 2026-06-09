import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/investment/widdgets/my_investment_card.dart';
import 'package:bostra/ui/investment/widdgets/my_startup_card.dart';
import 'package:flutter/material.dart';

class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  int currentTab = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Investments & Startups"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
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
              labelPadding: EdgeInsets.symmetric(horizontal: 12),
              labelStyle: AppTextStyle.bodyText1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
              unselectedLabelStyle: AppTextStyle.bodyText1.copyWith(
                fontWeight: FontWeight.w100,
              ),
              indicatorPadding: EdgeInsetsGeometry.only(bottom: 4),
              indicator: UnderlineTabIndicator(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(width: 4, color: AppColors.primaryColor),
              ),
              tabs: [
                Tab(text: "Investments"),
                Tab(text: "My Startups"),
              ],
            ),
            SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                children: [
                  ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return MyInvestmentCard();
                    },
                  ),
                  ListView.builder(
                    itemCount: 1,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return MyStartupCard(
                        collectedAmount: 20000,
                        requestedAmount: 120000,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
