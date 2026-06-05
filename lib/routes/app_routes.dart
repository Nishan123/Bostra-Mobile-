import 'dart:async';
import 'package:bostra/ui/auth/login_screen.dart';
import 'package:bostra/ui/auth/otp_screen.dart';
import 'package:bostra/ui/main/main_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static final _authStateListenable = _AuthStateListenable();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: _authStateListenable,

    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final loggedIn = session != null;
      final location = state.matchedLocation;

      if (!loggedIn) {
        if (location == '/login' || location == '/otp') {
          return null;
        }
        return '/login';
      }
      if (location == '/main') {
        return null;
      }
      if (location == '/login' || location == '/otp') {
        return '/main';
      }
      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) => const OtpScreen(),
      ),

      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) => const MainScreen(),
      ),
    ],
  );
}

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
