import 'dart:convert';

import 'package:appka/config/config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

part "document_state.dart";

class DocumentCubit extends Cubit<DocumentState>{
  DocumentCubit() : super(const DocumentInitial());

  void addDocument(Map<String, dynamic> documentData) async{
    emit(const DocumentLoading());

    try{
      final uri = Uri.parse('http://${ApiConfig.baseUrl}/document/add');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'patient_first_name': documentData['patient_first_name'],
          'patient_last_name': documentData['patient_last_name'],
          'visit_date': documentData['visit_date'],
          'diagnosis': documentData['diagnosis'],
          'recommendations': documentData['recommendations'],
          'doctor_name': documentData['doctor_name'],
          'document_type': documentData['document_type'],
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
      final uri = Uri.parse(
          'http:/${ApiConfig.baseUrl}/document/get-patients-docs?first_name=$firstName&last_name=$lastName'
      );
      final response = await http.get(uri);

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

}