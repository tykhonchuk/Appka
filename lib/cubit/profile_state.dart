part of "profile_cubit.dart";

sealed class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileSuccess extends ProfileState {
  const ProfileSuccess([this.token]);
  final String? token;
}

class ProfileError extends ProfileState {
  const ProfileError({this.error, this.message});
  final Object? error;
  final String? message;
}
