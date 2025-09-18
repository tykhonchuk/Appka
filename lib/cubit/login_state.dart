part of "login_cubit.dart";

sealed class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState{
  const LoginSuccess({required this.username, required this.token});

  final String username;
  final String token;
}

class LoginError extends LoginState{
  const LoginError({this.error, this.message});

  final Object? error;
  final String? message;
}

