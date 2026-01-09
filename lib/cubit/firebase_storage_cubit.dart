import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part "firebase_storage_state.dart";

class FirebaseStorageCubit extends Cubit<FirebaseState> {
  FirebaseStorageCubit() : super(const FirebaseInitial());

  Future<String?> uploadFile(File file) async {
    try {

      if (!await file.exists()) {
        return null;
      }
      String ext = '';
      final path = file.path;
      if (path.contains('.')){
        ext = path.split('.').last.toLowerCase();
      }
      if (ext.isEmpty){
        ext = 'png';
      }

      var user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        final cred = await FirebaseAuth.instance.signInAnonymously();
        user = cred.user;
      }

      if (user == null) {
        return null;
      }

      final uid = user.uid;
      final fileName = "${DateTime
          .now()
          .millisecondsSinceEpoch}.$ext";

      final ref = FirebaseStorage.instance
          .ref()
          .child("documents")
          .child(uid)
          .child(fileName);

      final snapshot = await ref.putFile(file);
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e, st) {
      return null;
    } catch (e, st) {
      return null;
    }
  }
}
