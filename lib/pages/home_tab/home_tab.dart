import 'dart:io';

import 'package:appka/config/pages_route.dart';
import 'package:appka/cubit/document_cubit.dart';
import 'package:appka/cubit/ocr_cubit.dart';
import 'package:appka/cubit/profile_cubit.dart';
import 'package:appka/pages/camera_page.dart';
import 'package:appka/pages/home_tab/documents_list.dart';
import 'package:appka/pages/home_tab/floating_actions.dart';
import 'package:appka/pages/home_tab/welcome_sliver_header.dart';
import 'package:appka/pages/home_tab/documents_filter_bar.dart';
import 'package:appka/pages/preview_pdf_page.dart';
import 'package:appka/pages/preview_photo_page.dart';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  String userFirstName = "";
  String userLastName = "";
  List<Map<String, dynamic>> userDocuments = [];

  // 🔍 wyszukiwanie
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ✅ nowe filtry (checkboxy)
  List<String> _selectedDoctors = [];
  List<String> _selectedDiagnoses = [];
  List<String> _selectedTypes = [];
  DateTime? _dateFrom;
  DateTime? _dateTo;

  File? pickedFile;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        final userCredential =
        await FirebaseAuth.instance.signInAnonymously();
        print('Zalogowano anonimowo. UID: ${userCredential.user?.uid}');
      } catch (e) {
        print('Błąd logowania anonimowego: $e');
      }

      await _loadUserName();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final profileCubit = context.read<ProfileCubit>();
    await profileCubit.fetchUser();
    final state = profileCubit.state;

    if (state is ProfileUserLoaded) {
      setState(() {
        userFirstName = state.firstName;
        userLastName = state.lastName;
      });
      await _loadUserDocuments();
    }
  }

  Future<void> _loadUserDocuments() async {
    final docCubit = context.read<DocumentCubit>();
    await docCubit.fetchDocumentsByPatientName(
        userFirstName, userLastName);
    final state = docCubit.state;

    if (state is DocumentLoadedList) {
      setState(() => userDocuments = state.documents);
    }
  }

  // ======================
  // ✅ DANE DO FILTRÓW
  // ======================

  List<String> get _availableDoctors {
    final set = <String>{};
    for (final doc in userDocuments) {
      final d = (doc['doctor_name'] ?? '').toString();
      if (d.isNotEmpty) set.add(d);
    }
    return set.toList();
  }

  List<String> get _availableDiagnoses {
    final set = <String>{};
    for (final doc in userDocuments) {
      final d = (doc['diagnosis'] ?? '').toString();
      if (d.isNotEmpty) set.add(d);
    }
    return set.toList();
  }

  List<String> get _availableTypes {
    final set = <String>{};
    for (final doc in userDocuments) {
      final t = (doc['document_type'] ?? '').toString();
      if (t.isNotEmpty) set.add(t);
    }
    return set.toList();
  }
  DateTime? _parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  // ======================
  // ✅ FILTROWANIE
  // ======================

  List<Map<String, dynamic>> get _filteredDocuments {
    List<Map<String, dynamic>> docs = List.from(userDocuments);

    // 🔍 tekst
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      docs = docs.where((doc) {
        final firstName =
        (doc['patient_first_name'] ?? '').toString().toLowerCase();
        final lastName =
        (doc['patient_last_name'] ?? '').toString().toLowerCase();
        final docType =
        (doc['document_type'] ?? '').toString().toLowerCase();
        final doctor =
        (doc['doctor_name'] ?? '').toString().toLowerCase();
        final diagnosis =
        (doc['diagnosis'] ?? '').toString().toLowerCase();
        final date =
        (doc['visit_date'] ?? '').toString().toLowerCase();

        return firstName.contains(q) ||
            lastName.contains(q) ||
            docType.contains(q) ||
            doctor.contains(q) ||
            diagnosis.contains(q) ||
            date.contains(q);
      }).toList();
    }
    // 📅 filtr po dacie (dd/MM/yyyy)
    if (_dateFrom != null || _dateTo != null) {
      docs = docs.where((doc) {
        final dateStr = (doc['visit_date'] ?? '').toString();
        if (dateStr.isEmpty) return false;

        final docDate = _parseDate(dateStr);
        if (docDate == null) return false;

        if (_dateFrom != null && docDate.isBefore(_dateFrom!)) {
          return false;
        }

        if (_dateTo != null && docDate.isAfter(_dateTo!)) {
          return false;
        }

        return true;
      }).toList();
    }

    // 👨‍⚕️ lekarz
    if (_selectedDoctors.isNotEmpty) {
      docs = docs.where((doc) {
        final name = (doc['doctor_name'] ?? '').toString();
        return _selectedDoctors.contains(name);
      }).toList();
    }

    // 🧾 diagnoza
    if (_selectedDiagnoses.isNotEmpty) {
      docs = docs.where((doc) {
        final diag = (doc['diagnosis'] ?? '').toString();
        return _selectedDiagnoses.contains(diag);
      }).toList();
    }

    // 📄 typ dokumentu
    if (_selectedTypes.isNotEmpty) {
      docs = docs.where((doc) {
        final type = (doc['document_type'] ?? '').toString();
        return _selectedTypes.contains(type);
      }).toList();
    }

    return docs;
  }

  // ======================
  // 📸 Kamera / galeria / PDF
  // ======================

  Future<void> _pickImageFromCamera(BuildContext context) async {
    if (_cameras.isEmpty) {
      try {
        _cameras = await availableCameras();
      } catch (e) {
        print("Błąd pobierania kamer: $e");
      }
    }

    if (_cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Brak dostępnej kamery")),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraScreen(
          camera: _cameras.first,
          onImageTaken: (path) async {
            final ocrCubit = context.read<OcrCubit>();
            pickedFile = File(path);
            await ocrCubit.sendFileForOcr(pickedFile!);
            final ocrState = ocrCubit.state;

            if (ocrState is OcrSuccess) {
              final extractedData = ocrState.extractedData;

              extractedData['file'] = pickedFile;
              extractedData['filename'] =
                  pickedFile!.path.split('/').last;
              extractedData['file_type'] =
                  pickedFile!.path.split('.').last;

              context.push(
                PagesRoute.editDocumentPage.path,
                extra: extractedData,
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewPhotoPage(
          imagePath: image.path,
          onAccept: () async {
            final file = File(image.path);

            final ocrCubit = context.read<OcrCubit>();
            await ocrCubit.sendFileForOcr(file);
            final ocrState = ocrCubit.state;

            if (ocrState is OcrSuccess) {
              final extractedData = ocrState.extractedData;

              pickedFile = file;
              extractedData['file'] = pickedFile;
              extractedData['filename'] =
                  pickedFile!.path.split('/').last;
              extractedData['file_type'] =
                  pickedFile!.path.split('.').last;

              context.push(
                PagesRoute.editDocumentPage.path,
                extra: extractedData,
              );
            }
          },
          onRetake: () {
            context.push(PagesRoute.cameraPage.path);
            _pickImageFromGallery(context);
          },
          onBack: () =>
              Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.single.path!);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewPDFPage(
          filePath: file.path,
          onBack: () => Navigator.pop(context),
          onPickAgain: () {
            Navigator.pop(context);
            _pickFile(context);
          },
          onApprove: () async {
            final ocrCubit = context.read<OcrCubit>();
            await ocrCubit.sendFileForOcr(file);
            final ocrState = ocrCubit.state;

            if (ocrState is OcrSuccess) {
              final extractedData = ocrState.extractedData;

              pickedFile = file;
              extractedData['file'] = pickedFile;
              extractedData['filename'] =
                  pickedFile!.path.split('/').last;
              extractedData['file_type'] =
                  pickedFile!.path.split('.').last;

              context.push(
                PagesRoute.editDocumentPage.path,
                extra: extractedData,
              );
            }
          },
        ),
      ),
    );
  }

  // ======================
  // 🧩 UI
  // ======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            WelcomeSliverHeader(userFirstName: userFirstName),
          ];
        },
        body: Column(
          children: [
            DocumentsFilterBar(
              searchController: _searchController,
              doctors: _availableDoctors,
              diagnoses: _availableDiagnoses,
              documentTypes: _availableTypes,
              selectedDoctors: _selectedDoctors,
              selectedDiagnoses: _selectedDiagnoses,
              selectedTypes: _selectedTypes,
              onDoctorsChanged: (list) {
                setState(() => _selectedDoctors = list);
              },
              onDiagnosesChanged: (list) {
                setState(() => _selectedDiagnoses = list);
              },
              onTypesChanged: (list) {
                setState(() => _selectedTypes = list);
              },
              dateFrom: _dateFrom,
              dateTo: _dateTo,
              onDateFromChanged: (date) {
                setState(() => _dateFrom = date);
              },
              onDateToChanged: (date) {
                setState(() => _dateTo = date);
              },
            ),

            Expanded(
              child: DocumentsList(
                documents: _filteredDocuments,
                userFirstName: userFirstName,
                userLastName: userLastName,
                onDelete: _loadUserDocuments,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActions(
        onPickCamera: () => _pickImageFromCamera(context),
        onPickGallery: () => _pickImageFromGallery(context),
        onPickFile: () => _pickFile(context),
      ),
    );
  }
}
