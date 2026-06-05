import 'package:bostra/ui/home/home_screen.dart';
import 'package:bostra/ui/investment/investments_screen.dart';
import 'package:bostra/ui/main/widgets/custom_buttom_nav_bar.dart';
import 'package:bostra/ui/portfolio/protfolio_screen.dart';
import 'package:bostra/ui/profile/profile_screen.dart';
import 'package:bostra/ui/saved/saved_startup_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> body = [
    HomeScreen(),
    SavedStartupScreen(),
    InvestmentsScreen(),
    PortfolioScreen(),
    ProfileScreen(),
  ];
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body[currentIndex],
      bottomNavigationBar: CustomButtomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
