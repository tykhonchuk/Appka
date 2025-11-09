import 'dart:io';
import "package:http/http.dart" as http;
import 'package:flutter_bloc/flutter_bloc.dart';

part "ocr_state.dart";

class OcrCubit extends Cubit<OcrState>{
  OcrCubit(): super(const OcrInitial());

  Future<void> sendImageForOcr(File imageFile) async{
    emit(OcrLoading());
    final uri = Uri.parse("http://127.0.0.1:8000/ocr/extract-text");

    try{
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200){
        final body = await response.stream.bytesToString();
        final text = body.contains("text") ? body.split('"text":"')[1].split('"')[0] : body;
        emit(OcrSuccess());
      }else{
        emit(OcrError(message: "Błąd serwera"));
      }
    } catch (e) {
      emit(OcrError(error: e, message: "Nie udało się wysłać zdjęcia"));
    }
    
  }
}