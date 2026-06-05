import 'package:bostra/constants/assets_path.dart';
import 'package:bostra/enums/chips_options.dart';
import 'package:bostra/ui/home/widgets/home_card.dart';
import 'package:bostra/ui/home/widgets/home_chips.dart';
import 'package:bostra/ui/home/widgets/home_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final mq = MediaQuery.of(context).size;

    return Scaffold(
      // app bar
      appBar: AppBar(
        title: SvgPicture.asset(
          "${AssetsPath.svgPath}logo_without_slogan.svg",
          width: 88,
        ),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(LucideIcons.bell)),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
             SizedBox(height: 12,),
              HomeSearchBar(onFilterTap: () {}),
              SizedBox(height: 14),
             HomeChips(values: ChipsOptions.values, labelBuilder: (options)=>options.text, iconBuilder: null),
              SizedBox(height: 14,),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 12,
                itemBuilder: ((context, index) {
                  return HomeCard(
                    requestedAmount: 120000,
                    collectedAmount: 12300,
                  );
                }),
              ),

              const SizedBox(height: 20),
             
            ],
          ),
        ),
      ),
    );
  }
}
