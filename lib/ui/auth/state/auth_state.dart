enum AuthStatus { initial, loading, success, error }

class AuthState {
  final AuthStatus? status;
  final String? errorMessage;
  final String? phoneNumber;
  // null = not yet checked, true = new user, false = existing user
  final bool? isNewUser;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.phoneNumber,
    this.isNewUser,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? phoneNumber,
    bool? isNewUser,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}
