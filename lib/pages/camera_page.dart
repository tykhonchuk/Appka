import 'dart:io';
import 'package:appka/config/pages_route.dart';
import 'package:appka/pages/preview_photo_page.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';

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
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewPhotoPage(
            imagePath: image.path,
            onAccept: () {
              widget.onImageTaken(image.path);
              Navigator.of(context).popUntil((route) => route.isFirst); // redirect to Home page
            },
            onRetake: () {
              Navigator.pop(context); // return to camera page
            },
          ),
        ),
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
        title: const Text("Kamera"),
        // backgroundColor: Colors.black,
        // foregroundColor: Colors.black,
      ),
      // backgroundColor: Colors.white,
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: CameraPreview(_controller),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: FloatingActionButton(
                  onPressed: _takePicture,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.camera_alt, color: Colors.black, size: 32),
                ),
              ),
            ],
          ),
        ),
    );
  }
}