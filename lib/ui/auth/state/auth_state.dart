enum AuthStatus { initial, loading, success, error }

class AuthState {
  final AuthStatus? status;
  final String? errorMessage;
  final String? phoneNumber;

  const AuthState({ this.status=AuthStatus.initial, this.errorMessage, this.phoneNumber});


  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? phoneNumber,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
