part of "signup_cubit.dart";

sealed class SignupState{
  const SignupState();
}

class SignupInitial extends SignupState{
  const SignupInitial();
}

class SignupLoading extends SignupState{
  const SignupLoading();
}

class SignupSuccess extends SignupState{
  const SignupSuccess();
}

class SignupError extends SignupState{
  const SignupError({this.error, this.message});

  final Object? error;
  final String? message;
}