import 'dart:io';

import 'package:appka/config/pages_route.dart';
import 'package:appka/cubit/document_cubit.dart';
import 'package:appka/cubit/firebase_storage_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditDocumentPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const EditDocumentPage({super.key, this.initialData});

  @override
  State<EditDocumentPage> createState() => _EditDocumentPageState();
}

class _EditDocumentPageState extends State<EditDocumentPage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController dateController;
  late TextEditingController diagnosisController;
  late TextEditingController recommendationsController;
  late TextEditingController doctorController;
  late TextEditingController docTypeController;

  File? pickedFile;
  String? ocrText;

  bool get isEdit => widget.initialData?["id"] != null;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(
      text: widget.initialData?["patient_first_name"] ?? "",
    );
    lastNameController = TextEditingController(
      text: widget.initialData?["patient_last_name"] ?? "",
    );
    dateController = TextEditingController(
      text: widget.initialData?["visit_date"] ?? "",
    );
    diagnosisController = TextEditingController(
      text: widget.initialData?["diagnosis"] ?? "",
    );
    recommendationsController = TextEditingController(
      text: widget.initialData?["recommendations"] ?? "",
    );
    doctorController = TextEditingController(
      text: widget.initialData?["doctor_name"] ?? "",
    );
    docTypeController = TextEditingController(
      text: widget.initialData?["document_type"] ?? "",
    );

    // plik może przyjść z OCR (nowy dokument)
    // przy edycji z listy zazwyczaj go nie będzie
    pickedFile = widget.initialData?["file"];
    ocrText = widget.initialData?["ocr_text"];
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dateController.dispose();
    diagnosisController.dispose();
    recommendationsController.dispose();
    doctorController.dispose();
    docTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentCubit, DocumentState>(
      listener: (context, state) async {
        if (state is DocumentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEdit ? "Dokument zaktualizowany!" : "Dokument dodany!",
              ),
            ),
          );

          if (isEdit) {
            // wracamy do poprzedniego ekranu i mówimy "zaktualizowano"
            Navigator.of(context).pop(true);
          } else {
            // nowy dokument – jak wcześniej, wracamy do home
            context.push(PagesRoute.homePage.path);
          }
        } else if (state is DocumentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message ?? (isEdit
                    ? "Błąd podczas edycji dokumentu"
                    : "Błąd podczas dodawania dokumentu"),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? "Edycja dokumentu" : "Nowy dokument"),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: "Imię"),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: "Nazwisko"),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: "Data wizyty"),
                ),
                TextField(
                  controller: diagnosisController,
                  decoration: const InputDecoration(labelText: "Rozpoznanie"),
                ),
                TextField(
                  controller: recommendationsController,
                  decoration: const InputDecoration(labelText: "Zalecenia"),
                ),
                TextField(
                  controller: doctorController,
                  decoration: const InputDecoration(labelText: "Lekarz"),
                ),
                TextField(
                  controller: docTypeController,
                  decoration:
                  const InputDecoration(labelText: "Rodzaj dokumentu"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final firebaseCubit =
                    context.read<FirebaseStorageCubit>();
                    final docCubit = context.read<DocumentCubit>();

                    // 1️⃣ dane pliku bazowe – z initialData (np. przy edycji)
                    String? fileUrl = widget.initialData?["file_url"];
                    String? filename = widget.initialData?["filename"];
                    String? fileType = widget.initialData?["file_type"];

                    // 2️⃣ jeśli mamy lokalny plik (np. z OCR / nowy dok)
                    //    lub dodasz później możliwość podmiany pliku przy edycji
                    final file = pickedFile;
                    if (file != null) {
                      // jeśli brak typu/nazwy, bierzemy z ścieżki
                      fileType ??= file.path.split('.').last;
                      filename ??= file.path.split('/').last;

                      final uploadedUrl = await firebaseCubit.uploadFile(file);
                      if (uploadedUrl != null) {
                        fileUrl = uploadedUrl;
                      }
                    }

                    // 3️⃣ fallbacki, gdyby nadal czegoś brakowało
                    fileType ??= "pdf";
                    filename ??=
                    "document_${DateTime.now().millisecondsSinceEpoch}.$fileType";

                    final payload = {
                      'patient_first_name': firstNameController.text,
                      'patient_last_name': lastNameController.text,
                      'visit_date': dateController.text,
                      'diagnosis': diagnosisController.text,
                      'recommendations': recommendationsController.text,
                      'doctor_name': doctorController.text,
                      'document_type': docTypeController.text,
                      'file_url': fileUrl,
                      'filename': filename,
                      'file_type': fileType,
                      'ocr_text': ocrText ?? "",
                    };

                    if (isEdit && widget.initialData?["id"] != null) {
                      // ✏️ tryb edycji
                      final id = widget.initialData!["id"] as int;
                      await docCubit.updateDocument(id, payload);
                    } else {
                      // ➕ nowy dokument
                      docCubit.addDocument(payload);
                    }
                  },
                  child: const Text("Zapisz"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
