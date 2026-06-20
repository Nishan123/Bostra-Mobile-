import 'dart:async';
import 'package:bostra/constants/table_names.dart';
import 'package:bostra/ui/auth/login_screen.dart';
import 'package:bostra/ui/auth/otp_screen.dart';
import 'package:bostra/ui/auth/user_details_screen.dart';
import 'package:bostra/ui/main/main_screen.dart';
import 'package:bostra/ui/start_campain/start_campain1.dart';
import 'package:bostra/ui/start_campain/start_campain2.dart';
import 'package:bostra/ui/start_campain/start_campain3.dart';
import 'package:bostra/ui/start_campain/start_campain4.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static final _routerListenable = _RouterRefreshNotifier();

  /// Call this after onboarding completes so the router re-evaluates access.
  static Future<void> refreshOnboardingStatus() =>
      _routerListenable._onAuthChanged(
        Supabase.instance.client.auth.currentSession,
      );

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: _routerListenable,

    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final loggedIn = session != null;
      final location = state.matchedLocation;

      // ── Not logged in ──────────────────────────────────────────────────────
      if (!loggedIn) {
        if (location == '/login' || location == '/otp') return null;
        return '/login';
      }

      // ── Logged in ──────────────────────────────────────────────────────────
      // Allow /otp freely — OtpScreen owns its navigation via _handleVerify.
      if (location == '/otp') return null;

      final onboardingDone = _routerListenable.onboardingComplete;

      // Still checking onboarding status — don't redirect yet.
      if (onboardingDone == null) return null;

      if (!onboardingDone) {
        // Onboarding incomplete: only allow the user-details screen.
        if (location == '/user-details') return null;
        return '/user-details';
      }

      // Onboarding complete: push auth screens away.
      if (location == '/login' || location == '/user-details') return '/main';

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
        path: '/user-details',
        name: 'userDetails',
        builder: (context, state) => const UserDetailsScreen(),
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/start-campaign-1',
        name: 'startCampaign1',
        builder: (context, state) => const StartCampain1(),
      ),
      GoRoute(
        path: '/start-campaign-2',
        name: 'startCampaign2',
        builder: (context, state) => const StartCampain2(),
      ),
      GoRoute(
        path: '/start-campaign-3',
        name: 'startCampaign3',
        builder: (context, state) => const StartCampain3(),
      ),
      GoRoute(
        path: '/start-campaign-4',
        name: 'startCampaign4',
        builder: (context, state) => const StartCampain4(),
      ),
    ],
  );
}

/// A [ChangeNotifier] that listens to Supabase auth state changes AND
/// performs an async onboarding check whenever the session changes.
///
/// [onboardingComplete] is:
///   - `null`  → check still in progress (router waits; no redirect issued)
///   - `false` → logged in but onboarding incomplete → router sends to /user-details
///   - `true`  → logged in and onboarding complete   → router allows /main
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier() {
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      _onAuthChanged(event.session);
    });

    // Run an immediate check for any pre-existing session on cold start.
    _onAuthChanged(Supabase.instance.client.auth.currentSession);
  }

  late final StreamSubscription<AuthState> _authSubscription;

  /// `null` = loading, `false` = incomplete, `true` = complete
  bool? onboardingComplete;

  Future<void> _onAuthChanged(Session? session) async {
    if (session == null) {
      // Logged out — clear cached state and notify.
      onboardingComplete = null;
      notifyListeners();
      return;
    }

    // A session exists — check if onboarding is done.
    onboardingComplete = null; // show loading state while we check
    notifyListeners();

    try {
      final userId = session.user.id;
      final response = await Supabase.instance.client
          .from(TableNames.usersTable)
          .select('full_name')
          .eq('id', userId)
          .maybeSingle();

      // Onboarding is considered complete when the user's row exists
      // AND full_name has been filled in (Step 1 of onboarding).
      onboardingComplete = response != null &&
          response['full_name'] != null &&
          (response['full_name'] as String).trim().isNotEmpty;
    } catch (_) {
      // Table may not exist yet or network error — treat as incomplete.
      onboardingComplete = false;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
