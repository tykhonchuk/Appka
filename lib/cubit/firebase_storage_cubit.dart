import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part "firebase_storage_state.dart";

class FirebaseStorageCubit extends Cubit<FirebaseState> {
  FirebaseStorageCubit() : super(const FirebaseInitial());



  Future<String?> uploadFile(File file) async {
    try {
      print('➡ uploadFile() – ścieżka lokalna: ${file.path}');

      if (!await file.exists()) {
        print("❌ Plik nie istnieje lokalnie!");
        return null;
      }

      // upewniamy się, że user jest zalogowany
      var user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        final cred = await FirebaseAuth.instance.signInAnonymously();
        user = cred.user;
      }

      if (user == null) {
        print('❌ Brak użytkownika – nie mogę uploadować.');
        return null;
      }

      final uid = user.uid;
      final fileName = "${DateTime
          .now()
          .millisecondsSinceEpoch}.png";
      print("➡ Nazwa pliku w Storage: $fileName, uid: $uid");

      // ŚCIEŻKA Z UID: documents/<uid>/<fileName>
      final ref = FirebaseStorage.instance
          .ref()
          .child("documents")
          .child(uid)
          .child(fileName);

      final snapshot = await ref.putFile(file);
      final url = await snapshot.ref.getDownloadURL();

      print("✅ Upload OK, URL: $url");
      return url;
    } on FirebaseException catch (e, st) {
      print("❌ FirebaseException przy uploadzie:");
      print("   code: ${e.code}");
      print("   message: ${e.message}");
      print("   stack: $st");
      return null;
    } catch (e, st) {
      print("❌ Inny błąd uploadu: $e");
      print(st);
      return null;
    }
  }
}
