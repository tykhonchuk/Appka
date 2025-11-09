import 'dart:convert';
import 'dart:io';
import 'package:appka/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

part "ocr_state.dart";

class OcrCubit extends Cubit<OcrState> {
  OcrCubit() : super(const OcrInitial());

  Future<void> sendFileForOcr(File file) async {
    emit(OcrLoading());
    final uri = Uri.parse("http://${ApiConfig.baseUrl}/ocr/extract-text");

    try {
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decoded = json.decode(responseBody);

        final text = decoded["text"] ?? "";
        final extractedData = decoded["extracted_data"] ?? {};
        print("📄 OCR extracted: $extractedData");

        emit(OcrSuccess(text: text, extractedData: extractedData));
      } else {
        emit(OcrError(message: "Błąd serwera (status ${response.statusCode})"));
      }
    } catch (e) {
      emit(OcrError(error: e, message: "Nie udało się wysłać pliku do OCR"));
    }
  }
}
