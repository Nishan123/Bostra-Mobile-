import 'package:bostra/routes/app_routes.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://pubxslcxrxmouapmnqlw.supabase.co',
    anonKey: 'sb_publishable_TermADrSy4LS__geQvLAXA_eo2AyLJZ',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Bostra',
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        appBarTheme: AppBarTheme(
          titleTextStyle: AppTextStyle.h3.copyWith(
            color: AppColors.primaryColor,
          ),
        ),
      ),
      routerConfig: AppRoutes.router,
    );
  }
}
