import 'dart:io';
import 'package:flutter/material.dart';

class PreviewPhotoPage extends StatelessWidget {
  final String imagePath;
  final VoidCallback onAccept;
  final VoidCallback onRetake;

  const PreviewPhotoPage({
    super.key,
    required this.imagePath,
    required this.onAccept,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Image.file(File(imagePath), fit: BoxFit.contain),
          ),
          Positioned(
            bottom: 50,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: "retake",
                  onPressed: onRetake,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.refresh, color: Colors.white),
                ),
                FloatingActionButton(
                  heroTag: "accept",
                  onPressed: onAccept,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.check, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
