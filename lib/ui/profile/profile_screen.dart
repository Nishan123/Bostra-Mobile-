import 'package:bostra/ui/auth/state/auth_state.dart';
import 'package:bostra/ui/auth/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.initial) {
        context.goNamed("login");
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? "Sign out failed"),
            backgroundColor: Colors.redAccent,
          ),
        );
        ref.read(authViewModelProvider.notifier).resetStatus();
      }
    });

    return Scaffold(
      body: Column(
        children: [
          Center(child: Text("Profile Screen")),
          ElevatedButton(
            onPressed: authState.status == AuthStatus.loading
                ? null
                : () {
                    ref.read(authViewModelProvider.notifier).signOut();
                  },
            child: authState.status == AuthStatus.loading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Log Out"),
          ),
        ],
      ),
    );
  }
}
