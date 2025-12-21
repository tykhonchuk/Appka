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

  String? _selectedDocType;
  bool _isDocTypeExpanded = false;

  final List<String> _docTypes = [
    'Karta informacyjna',
    'Wyniki badań',
    'Recepta',
    'Zaświadczenie lekarskie',
    'Inny',
  ];

  bool get _showDiagnosis =>
      _selectedDocType == 'Karta informacyjna' ||
          _selectedDocType == 'Zaświadczenie lekarskie';

  bool get _showRecommendations =>
      _selectedDocType == 'Karta informacyjna' ||
          _selectedDocType == 'Zaświadczenie lekarskie';

  bool get _showDoctor =>
      _selectedDocType == 'Karta informacyjna' ||
          _selectedDocType == 'Zaświadczenie lekarskie' ||
          _selectedDocType == 'Recepta' ||
          _selectedDocType == 'Wyniki badań';

  bool get isEdit => widget.initialData?["id"] != null;

  @override
  void initState() {
    super.initState();

    firstNameController = TextEditingController(text: widget.initialData?["patient_first_name"] ?? "");
    lastNameController = TextEditingController(text: widget.initialData?["patient_last_name"] ?? "");
    dateController = TextEditingController(text: widget.initialData?["visit_date"] ?? "");
    diagnosisController = TextEditingController(text: widget.initialData?["diagnosis"] ?? "");
    recommendationsController = TextEditingController(text: widget.initialData?["recommendations"] ?? "");
    doctorController = TextEditingController(text: widget.initialData?["doctor_name"] ?? "");
    docTypeController = TextEditingController(text: widget.initialData?["document_type"] ?? "");

    pickedFile = widget.initialData?["file"];
    ocrText = widget.initialData?["ocr_text"];

    if (docTypeController.text.isNotEmpty) {
      _selectedDocType = docTypeController.text;
    }
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

  // ██████████████████████████████████████
  // „ŁADNY” DROPDOWN – JAK TEXTFIELD
  // ██████████████████████████████████████

  Widget _buildDocTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isDocTypeExpanded = !_isDocTypeExpanded;
            });
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Rodzaj dokumentu',
              labelStyle: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w500,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Colors.blueAccent, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedDocType ?? "Wybierz rodzaj dokumentu",
                    style: TextStyle(
                      fontSize: 14,
                      color: _selectedDocType == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                Icon(
                  _isDocTypeExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),

        if (_isDocTypeExpanded)
          Card(
            elevation: 4,
            margin: const EdgeInsets.only(top: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: _docTypes.map((type) {
                final isSelected = type == _selectedDocType;
                return ListTile(
                  dense: true,
                  title: Text(
                    type,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedDocType = type;
                      docTypeController.text = type;
                      _isDocTypeExpanded = false;
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  // ██████████████████████████████████████
  //               BUILD
  // ██████████████████████████████████████

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentCubit, DocumentState>(
      listener: (context, state) async {
        if (state is DocumentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEdit ? "Dokument zaktualizowany!" : "Dokument dodany!")),
          );

          isEdit
              ? Navigator.of(context).pop(true)
              : context.push(PagesRoute.homePage.path);
        } else if (state is DocumentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message ?? (isEdit ? "Błąd podczas edycji" : "Błąd podczas dodawania"),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? "Edycja dokumentu" : "Nowy dokument",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 12),

                _buildDocTypeField(),
                const SizedBox(height: 12),
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: "Imię"),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: "Nazwisko"),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: "Data wizyty"),
                ),


                if (_showDiagnosis)
                  TextField(
                    controller: diagnosisController,
                    decoration: const InputDecoration(labelText: "Rozpoznanie"),
                  ),
                if (_showDiagnosis) const SizedBox(height: 12),

                if (_showRecommendations)
                  TextField(
                    controller: recommendationsController,
                    decoration: const InputDecoration(labelText: "Zalecenia"),
                  ),
                if (_showRecommendations) const SizedBox(height: 12),

                if (_showDoctor)
                  TextField(
                    controller: doctorController,
                    decoration: const InputDecoration(labelText: "Lekarz"),
                  ),
                if (_showDoctor) const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () async {
                      final firebaseCubit = context.read<FirebaseStorageCubit>();
                      final docCubit = context.read<DocumentCubit>();

                      String? fileUrl = widget.initialData?["file_url"];
                      String? filename = widget.initialData?["filename"];
                      String? fileType = widget.initialData?["file_type"];

                      final file = pickedFile;
                      if (file != null) {
                        fileType ??= file.path.split('.').last;
                        filename ??= file.path.split('/').last;
                        final uploadedUrl = await firebaseCubit.uploadFile(file);
                        if (uploadedUrl != null) fileUrl = uploadedUrl;
                      }

                      fileType ??= "pdf";
                      filename ??= "document_${DateTime.now().millisecondsSinceEpoch}.$fileType";

                      int? fileSizeBytes;
                      if (pickedFile != null && await pickedFile!.exists()) {
                        fileSizeBytes = await pickedFile!.length();
                      }

                      final payload = {
                        'patient_first_name': firstNameController.text,
                        'patient_last_name': lastNameController.text,
                        'visit_date': dateController.text,
                        'diagnosis': diagnosisController.text,
                        'recommendations': recommendationsController.text,
                        'doctor_name': doctorController.text,
                        'document_type': _selectedDocType ?? docTypeController.text,
                        'file_url': fileUrl,
                        'filename': filename,
                        'file_type': fileType,
                        'ocr_text': ocrText ?? "",
                        'file_size_bytes': fileSizeBytes,
                      };

                      if (isEdit) {
                        await docCubit.updateDocument(widget.initialData!["id"], payload);
                      } else {
                        docCubit.addDocument(payload);
                      }
                    },
                    child: const Text("Zapisz", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
