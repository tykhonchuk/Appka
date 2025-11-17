import 'dart:io';
import 'package:appka/config/pages_route.dart';
import 'package:appka/cubit/document_cubit.dart';
import 'package:appka/cubit/ocr_cubit.dart';
import 'package:appka/cubit/profile_cubit.dart';
import 'package:appka/pages/camera_page.dart';
import 'package:appka/pages/home_tab/documents_list.dart';
import 'package:appka/pages/home_tab/floating_actions.dart';
import 'package:appka/pages/home_tab/welcome_header.dart';
import 'package:appka/pages/preview_pdf_page.dart';
import 'package:appka/pages/preview_photo_page.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  late List<CameraDescription> _cameras;
  String userFirstName = "";
  String userLastName = "";
  List<Map<String, dynamic>> userDocuments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _loadUserName();
      await _initCamera();
    });
  }

  //zamykanie kamery gdy przechodzi sie na inną stronę
  @override
  void dispose() {
    _controller?.dispose();
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
        _controller = CameraController(_cameras.first, ResolutionPreset.medium);
        await _controller!.initialize();
        if (!mounted) return;
        setState(() {});
      }
    } catch (e) {
      print("Błąd inicjalizacji kamery: $e");
    }
  }

  Future<String> _sendToFirebase(File file)async{
    final fileName = file.path.split('/').last;
    final storageRef = FirebaseStorage.instance.ref();
    final fileRef = storageRef.child("documents/${DateTime.now().millisecondsSinceEpoch}_$fileName");
    await fileRef.putFile(file);
    final downloadUrl = await fileRef.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _pickImageFromCamera(BuildContext context) async {
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
            await ocrCubit.sendFileForOcr(File(path));
            final ocrState = ocrCubit.state;
            if (ocrState is OcrSuccess) {
              context.push(
                  PagesRoute.editDocumentPage.path,
                  extra: ocrState.extractedData);
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

    // Otwórz podgląd zdjęcia
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewPhotoPage(
          imagePath: image.path,
          onAccept: () async{
            final file = File(image.path);

            final downloadUrl = await _sendToFirebase(file);

            final ocrCubit = context.read<OcrCubit>();
            await ocrCubit.sendFileForOcr(file);
            final ocrState = ocrCubit.state;

            if (ocrState is OcrSuccess) {
              final extractedData = ocrState.extractedData;

              extractedData['file_url'] = downloadUrl;
              extractedData['filename'] = file.path.split('/').last;
              extractedData['file_type'] = file.path.split('.').last;

              //await context.read<DocumentCubit>().addDocument(extractedData);
              context.push(PagesRoute.editDocumentPage.path, extra: extractedData);
            }
            // Navigator.of(context).popUntil((route) => route.isFirst); // zamyka preview i zostawia zdjęcie w liście
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text("✅ Zdjęcie zapisane!")),
            // );
          },
          onRetake: () {
            context.push(PagesRoute.cameraPage.path); // zamyka preview i możesz ponownie wybrać zdjęcie
            _pickImageFromGallery(context);
          },
          onBack: () => Navigator.of(context).popUntil((route) => route.isFirst), // powrót bez zmian
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
            await ocrCubit.sendFileForOcr(File(file.path));
            final ocrState = ocrCubit.state;

            if (ocrState is OcrSuccess) {
              final extractedData = ocrState.extractedData;


              //await context.read<DocumentCubit>().addDocument(extractedData);
              context.push(
                  PagesRoute.editDocumentPage.path, extra: extractedData);

            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WelcomeHeader(userFirstName: userFirstName),
          Expanded(
            child: DocumentsList(
              documents: userDocuments,
              userFirstName: userFirstName,
              userLastName: userLastName,
              onDelete: _loadUserDocuments,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActions(
        onPickCamera: () => _pickImageFromCamera(context),
        onPickGallery: () => _pickImageFromGallery(context),
        onPickFile: () => _pickFile(context),
      ),
    );
  }
}
