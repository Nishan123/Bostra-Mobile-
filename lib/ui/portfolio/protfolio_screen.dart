import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/ui/portfolio/widgets/invested_company_tile.dart';
import 'package:bostra/ui/portfolio/widgets/portfolio_pie_chart.dart';
import 'package:bostra/ui/portfolio/widgets/summary_paragraph.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:bostra/widgets/widget_title.dart';
import 'package:flutter/material.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Portfolio"),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              // Invested Companies
              WidgetTitle(text: "Invested Companies"),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return InvestedCompanyTile();
                },
              ),

              // Investment Diversity Graph
              SizedBox(height: 18),
              WidgetTitle(text: "Investment Diversity"),
              PortfolioPieChart(),

              // Ai summary
              SizedBox(height: 18),
              WidgetTitle(text: "AI Summary"),
              SummaryParagraph(
                text:
                    "Kaayar jo the, woh shaayar bane. Ab kya-kya karein yeh ishq mein. Na kehte the kuch jo, lage khoj mein. Kya lafz chune, naye aashiq yeh. Ishq mein tere hain Faiz bane. Arz kiya hai. Humne bhi likha kuch tere baare mein hai. Aise tu lage ki gulaab hai. Aur aise tu lage ki gulaab hai. Baaghon mein dil ke khilke inn fizaaon mein chhaye ho, haaye. Aur waise hum toh tere hi ghulaam hain. Aur waise hum toh tere hi ghulaam hain. Baadshah dil ke, teri baazi mein jo tu ch ... Read More",
              ),
              PrimaryButton(
                margin: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 24,
                  bottom: 24,
                ),
                text: "Ask More",
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
