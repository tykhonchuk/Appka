import "dart:io";
import "package:appka/config/pages_route.dart";
import "package:appka/cubit/ocr_cubit.dart";
import "package:appka/pages/home_page.dart";
import "package:flutter/material.dart";
import "package:camera/camera.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final Function(String path) onImageTaken;

  const CameraScreen({
    super.key,
    required this.camera,
    required this.onImageTaken,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _controller.initialize();
    if (!mounted) return;
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      final image = await _controller.takePicture();

      // przekazujemy dane do PreviewPhotoPage przez GoRouter
      context.push(
        PagesRoute.previewPhotoPage.path,
        extra: {
          'imagePath': image.path,
          'onBack': () => context.pop(),
          'onAccept': () async {
            widget.onImageTaken(image.path);
            final ocrCubit = context.read<OcrCubit>();
            await ocrCubit.sendFileForOcr(File(image.path));
            context.push(PagesRoute.editDocumentPage.path, extra: ocrCubit.state is OcrSuccess
                ? (ocrCubit.state as OcrSuccess).extractedData
                : null);
          },
          'onRetake': () => context.push(PagesRoute.cameraPage.path, extra: widget.camera),
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Błąd podczas robienia zdjęcia: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Zrób zdjęcie"),
        automaticallyImplyLeading: false //no arrow back
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(child: CameraPreview(_controller)),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: 'close_camera_button',
                    onPressed:(){ //context.go(PagesRoute.homePage.path);
                      context.pop();
                      // final home = HomePage.of(context);
                      // if (home != null) {
                      //   home.setIndex(0); // HomeTab
                      //   Navigator.of(context).popUntil((route) => route.isFirst);
                      // } else {
                      //   // Jeśli HomePage nie istnieje, stwórz nową instancję
                      //   context.go(PagesRoute.homePage.path, extra: 0);
                      // }
                    },
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.close, color: Colors.blueAccent, size: 32),
                  ),
                  const SizedBox(width: 40),

                  FloatingActionButton(
                      onPressed: _takePicture,
                      backgroundColor: Colors.blueAccent,
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
