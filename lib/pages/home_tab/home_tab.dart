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
    _loadUserName();
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
      _loadUserDocuments();
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
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _controller = CameraController(_cameras.first, ResolutionPreset.medium);
      await _controller!.initialize();
      setState(() {});
    }
  }

  Future<void> _pickImageFromCamera(BuildContext context) async {
    if (_cameras.isEmpty) return;
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
            // setState(() => items.add(image.path));

            final ocrCubit = context.read<OcrCubit>();
            await ocrCubit.sendFileForOcr(File(image.path));
            final ocrCubitState = ocrCubit.state;
            final ocrState = ocrCubit.state;
            if (ocrState is OcrSuccess) {
              final extractedData = ocrState.extractedData;
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

    // nie dodajemy od razu do items

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
          onApprove: () {
            // setState(() => items.add(file.path));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ PDF zaakceptowany!")),
            );
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
