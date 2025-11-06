import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:appka/config/pages_route.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'camera_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> items = [];

  CameraController? _controller;
  late List<CameraDescription> _cameras;

  @override
  void initState() {
    super.initState();
    _initCamera();
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
    if (_cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Brak dostępnej kamery")),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraScreen(
          camera: _cameras.first,
          onImageTaken: (path) {
            setState(() {
              items.add(path);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ Zdjęcie zapisane!")),
            );
          },
        ),
      ),
    );
  }


  Future<void> _pickImageFromGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Nie wybrano zdjęcia")),
        );
        return;
      }

      setState(() {
        items.add(image.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Zdjęcie dodane z galerii")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd podczas wyboru zdjęcia: $e")),
      );
    }
  }


  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);

      setState(() {
        items.add(file.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Plik PDF dodany")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Nie wybrano pliku")),
      );
    }
  }


  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Potwierdzenie"),
        content: const Text("Czy na pewno chcesz się wylogować?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Anuluj"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push(PagesRoute.loginPage.path);
            },
            child: const Text("Wyloguj"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == "profile") context.push(PagesRoute.profilePage.path);
              if (value == "logout") _confirmLogout(context);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "profile", child: Text("Ustawienia profilu")),
              PopupMenuItem(value: "logout", child: Text("Wyloguj się")),
            ],
          ),
        ],
      ),
      body: items.isNotEmpty
          ? ListView.builder(
        itemCount: items.length,
          itemBuilder: (_, index) {
            final path = items[index];
            final isImage = path.toLowerCase().endsWith('.jpg') ||
                path.toLowerCase().endsWith('.jpeg') ||
                path.toLowerCase().endsWith('.png');

            return ListTile(
              leading: isImage
                  ? Image.file(
                File(path),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
              title: Text(
                path.split('/').last, // pokazuje tylko nazwę pliku
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          },
      )
          : const Center(
        child: Text(
          "Brak dokumentów",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),

      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        spacing: 10,
        overlayOpacity: 0.4,
        overlayColor: Colors.black,
        curve: Curves.easeInOutCubic,
        childrenButtonSize: const Size(60, 60),
        elevation: 8,

        children: [
          SpeedDialChild(
            child: const Icon(Icons.camera_alt),
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.blueGrey.shade800,
            //label: "Zrób zdjęcie",
            //labelStyle: const TextStyle(fontSize: 16),
            onTap: () => _pickImageFromCamera(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.photo_library),
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.teal.shade700,
            //label: "Z galerii",
            //labelStyle: const TextStyle(fontSize: 16),
            onTap: () => _pickImageFromGallery(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.attach_file),
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.deepPurple.shade400,
            //label: "Z plików",
            labelStyle: const TextStyle(fontSize: 16),
            onTap: () => _pickFile(context),
          ),
        ],
      ),
    );
  }
}
