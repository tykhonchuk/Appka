import 'dart:io';
import 'package:appka/config/pages_route.dart';
import 'package:appka/cubit/ocr_cubit.dart';
import 'package:appka/pages/preview_pdf_page.dart';
import 'package:appka/pages/preview_photo_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:camera/camera.dart';
import '../cubit/profile_cubit.dart';
import 'camera_page.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<String> items = [];
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  String userName = "";

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final cubit = context.read<ProfileCubit>();
      await cubit.fetchUser(); // wywołuje request do backendu
      final state = cubit.state;
      if (state is ProfileUserLoaded) {
        setState(() {
          userName = state.firstName; // zapis do stanu
        });
      }
    } catch (e) {
      setState(() {
        userName = "Użytkownik";
      });
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
          onImageTaken: (path) {
            setState(() => items.add(path));

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
            if (ocrCubitState is OcrSuccess ){
              context.push(
                PagesRoute.addDocumentPage.path,
                extra: ocrCubitState.extractedData,
              );
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
            setState(() => items.add(file.path));
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
      // appBar: AppBar(title: const Text("Home")),
      body: Column(
        children: [
          // Kontener powitalny
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent.shade700, Colors.blueAccent.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  offset: const Offset(0, 5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // wyrównanie do lewej
                children: [
                  Text(
                    "Cześć, $userName!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Miło Cię znowu widzieć",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Lista dokumentów
          Expanded(
            child: items.isNotEmpty
                ? ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, index) {
                final path = items[index];
                final isImage = path.endsWith('.jpg') || path.endsWith('.png');
                return ListTile(
                  leading: isImage
                      ? Image.file(File(path), width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                  title: Text(path.split('/').last),
                );
              },
            )
                : const Center(child: Text("Brak dokumentów")),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        // spacing: 10,
        // spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: Icon(Icons.camera_alt, color: Theme.of(context).brightness == Brightness.dark
                ? Colors.blueGrey.shade200   // jaśniejszy kolor dla dark mode
                : Colors.blueGrey.shade700,),
            // foregroundColor: Colors.blueGrey.shade800,
            onTap: () => _pickImageFromCamera(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.photo_library),
            foregroundColor: Colors.teal.shade700,
            onTap: () => _pickImageFromGallery(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.attach_file),
            foregroundColor: Colors.deepPurple.shade400,
            onTap: () => _pickFile(context),
          ),
        ],
      ),
    );
  }
}
