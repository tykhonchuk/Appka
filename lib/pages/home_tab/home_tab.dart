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

  // 🔍 wyszukiwanie + filtr
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedType = 'Wszystkie';

  File? pickedFile;

  @override
  void initState() {
    super.initState();

    // reagujemy na wpisywanie w polu szukania
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // anonimowe logowanie do Firebase (na wszelki wypadek)
      try {
        final userCredential = await FirebaseAuth.instance.signInAnonymously();
        print('Zalogowano anonimowo. UID: ${userCredential.user?.uid}');
      } catch (e) {
        print('Błąd logowania anonimowego: $e');
      }

      await _loadUserName();
      // jeśli chcesz używać kamerę, możesz odkomentować:
      // await _initCamera();
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
    await docCubit.fetchDocumentsByPatientName(userFirstName, userLastName);
    final state = docCubit.state;
    if (state is DocumentLoadedList) {
      setState(() => userDocuments = state.documents);
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(
          _cameras.first,
          ResolutionPreset.medium,
        );
        await _controller!.initialize();
        if (!mounted) return;
        setState(() {});
      }
    } catch (e) {
      print("Błąd inicjalizacji kamery: $e");
    }
  }

  // 🔍 LOGIKA FILTROWANIA

  List<Map<String, dynamic>> get _filteredDocuments {
    List<Map<String, dynamic>> docs = List.from(userDocuments);

    // filtr tekstowy
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      docs = docs.where((doc) {
        final firstName =
        (doc['patient_first_name'] ?? '').toString().toLowerCase();
        final lastName =
        (doc['patient_last_name'] ?? '').toString().toLowerCase();
        final docType =
        (doc['document_type'] ?? '').toString().toLowerCase();
        final doctorName =
        (doc['doctor_name'] ?? '').toString().toLowerCase();
        final visitDate =
        (doc['visit_date'] ?? '').toString().toLowerCase(); // 👈 NOWE

        return firstName.contains(q) ||
            lastName.contains(q) ||
            docType.contains(q) ||
            doctorName.contains(q) ||
            visitDate.contains(q); // 👈 NOWE
      }).toList();
    }

    // filtr po typie dokumentu
    if (_selectedType != 'Wszystkie') {
      docs = docs.where((doc) {
        return (doc['document_type'] ?? '') == _selectedType;
      }).toList();
    }

    return docs;
  }

  List<String> get _availableTypes {
    final types = <String>{};
    for (final doc in userDocuments) {
      final t = (doc['document_type'] ?? '').toString();
      if (t.isNotEmpty) types.add(t);
    }
    return ['Wszystkie', ...types.toList()];
  }

  Future<void> _pickImageFromCamera(BuildContext context) async {
    if (_cameras.isEmpty) {
      // gdyby _initCamera nie zostało wywołane
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
              extractedData['filename'] = pickedFile!.path.split('/').last;
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
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
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
              extractedData['filename'] = pickedFile!.path.split('/').last;
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
              Navigator.of(context).popUntil((route) => route.isFirst),
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
              extractedData['filename'] = pickedFile!.path.split('/').last;
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
            // 🔍 szeroki pasek szukania + ikonka filtra po prawej
            DocumentsFilterBar(
              searchController: _searchController,
              selectedType: _selectedType,
              availableTypes: _availableTypes,
              onTypeChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),

            // 📄 lista dokumentów (już przefiltrowana)
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
