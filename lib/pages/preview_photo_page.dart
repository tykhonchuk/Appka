import 'dart:io';
import 'package:flutter/material.dart';

class PreviewPhotoPage extends StatelessWidget {
  final String imagePath;
  final VoidCallback onAccept;
  final VoidCallback onRetake;
  final VoidCallback onBack;

  const PreviewPhotoPage({
    super.key,
    required this.imagePath,
    required this.onAccept,
    required this.onRetake,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              width: 500,
              height: 500,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Wróć na główną stronę
                FloatingActionButton(
                  heroTag: "back",
                  onPressed: onBack,
                  backgroundColor: Colors.grey,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                const SizedBox(width: 20),
                // 2. Ponów zdjęcie / kamera
                FloatingActionButton(
                  heroTag: "retake",
                  onPressed: onRetake,
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.refresh, color: Colors.white),
                ),
                const SizedBox(width: 20),
                // 3. Akceptuj zdjęcie
                FloatingActionButton(
                  heroTag: "accept",
                  onPressed: onAccept,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.check, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
