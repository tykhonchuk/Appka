part of 'family_cubit.dart';


sealed class FamilyState {
  const FamilyState();
}

class FamilyInitial extends FamilyState {
  const FamilyInitial();
}

class FamilyLoading extends FamilyState {
  const FamilyLoading();
}

class FamilyLoaded extends FamilyState {
  final List<Map<String, dynamic>> members;
  const FamilyLoaded({required this.members});
}

class FamilySuccess extends FamilyState {
  const FamilySuccess([this.token]);
  final String? token;
}

class FamilyDeleteSuccess extends FamilyState {
  const FamilyDeleteSuccess();
}

class FamilyError extends FamilyState {
  const FamilyError({this.error, this.message});
  final Object? error;
  final String? message;
}
