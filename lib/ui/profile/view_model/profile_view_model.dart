import 'package:bostra/controllers/user_controller.dart';
import 'package:bostra/ui/profile/state/profile_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileViewModelProvider =
    NotifierProvider.autoDispose<ProfileViewModel, ProfileState>(ProfileViewModel.new);

class ProfileViewModel extends AutoDisposeNotifier<ProfileState> {
  late final UserController _userController;

  @override
  ProfileState build() {
    _userController = ref.read(userControllerProvider);
    // Automatically fetch on first build.
    Future.microtask(fetchCurrentUser);
    return const ProfileState();
  }

  /// Fetches the currently logged-in user's data from the users table.
  Future<void> fetchCurrentUser() async {
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser == null) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: 'No authenticated user found.',
      );
      return;
    }

    state = state.copyWith(status: ProfileStatus.loading);

    final phone = authUser.phone ?? '';
    final result = await _userController.getUserByPhone(phone);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.errorMessage,
        );
      },
      (user) {
        state = state.copyWith(
          status: ProfileStatus.success,
          user: user,
        );
      },
    );
  }
}
