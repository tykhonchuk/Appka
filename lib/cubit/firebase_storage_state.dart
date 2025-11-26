part of 'firebase_storage_cubit.dart';


sealed class FirebaseState {
  const FirebaseState();
}

class FirebaseInitial extends FirebaseState {
  const FirebaseInitial();
}

class FirebaseLoading extends FirebaseState {
  const FirebaseLoading();
}



class FirebaseSuccess extends FirebaseState {
  const FirebaseSuccess([this.token]);
  final String? token;
}

class FirebaseError extends FirebaseState {
  const FirebaseError({this.error, this.message});
  final Object? error;
  final String? message;
}
