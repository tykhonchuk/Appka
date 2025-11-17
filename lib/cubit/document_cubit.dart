import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appka/config/config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

part "document_state.dart";

class DocumentCubit extends Cubit<DocumentState>{
  DocumentCubit() : super(const DocumentInitial());

  void addDocument(Map<String, dynamic> documentData) async{
    emit(const DocumentLoading());

    try{
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final uri = Uri.parse('http://${ApiConfig.baseUrl}/document/add');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'patient_first_name': documentData['patient_first_name'],
          'patient_last_name': documentData['patient_last_name'],
          'visit_date': documentData['visit_date'],
          'diagnosis': documentData['diagnosis'],
          'recommendations': documentData['recommendations'],
          'doctor_name': documentData['doctor_name'],
          'document_type': documentData['document_type'],
          'filename': documentData['filename'],
          'file_type': documentData['file_type'],
          'file_url': documentData['file_url'],
          'ocr_text': documentData['ocr_text'] ?? "",
        }),
      );
      if (response.statusCode == 200) {
        emit(const DocumentSuccess());
      } else {
        final error = jsonDecode(response.body)["detail"] ?? "Nieznany błąd";
        emit(DocumentError(message: error));
      }

    } catch (e){
      emit(DocumentError(error: e, message: "Błąd dodawania dokumentu"));
    }
  }

  Future<void> fetchDocumentsByPatientName(String firstName, String lastName) async {
    emit(const DocumentLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final uri = Uri.parse(
          'http://${ApiConfig.baseUrl}/document/get-patients-docs?first_name=$firstName&last_name=$lastName'
      );
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        }
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final documents = data.map((e) => e as Map<String, dynamic>).toList();
        emit(DocumentLoadedList(documents: documents));
      } else {
        final error = jsonDecode(response.body)["detail"] ?? "Nieznany błąd";
        emit(DocumentError(message: error));
      }
    } catch (e) {
      emit(DocumentError(message: "Nie udało się załadować dokumentów", error: e));
    }
  }

  Future<void> fetchUserDocuments() async {
    emit(const DocumentLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final uri = Uri.parse('http://${ApiConfig.baseUrl}/document/get-user-docs'); // nowy endpoint
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final documents = data.map((e) => e as Map<String, dynamic>).toList();
        emit(DocumentLoadedList(documents: documents));
      } else {
        final error = jsonDecode(response.body)["detail"] ?? "Nieznany błąd";
        emit(DocumentError(message: error));
      }
    } catch (e) {
      emit(DocumentError(message: "Nie udało się załadować dokumentów", error: e));
    }
  }

  Future<void> deleteDocument(int documentId, String firstName, String lastName) async {
    emit(const DocumentLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final uri = Uri.parse('http://${ApiConfig.baseUrl}/document/delete-document/$documentId');
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        // odśwież listę dokumentów
        await fetchDocumentsByPatientName(firstName, lastName);
      } else {
        final error = jsonDecode(response.body)["detail"] ?? "Nieznany błąd";
        emit(DocumentError(message: error));
      }
    } catch (e) {
      emit(DocumentError(message: "Nie udało się usunąć dokumentu", error: e));
    }
  }
}