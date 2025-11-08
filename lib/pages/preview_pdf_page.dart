import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class PreviewPDFPage extends StatelessWidget {
  final String filePath;
  final VoidCallback onBack;      // powrót do Home
  final VoidCallback onApprove;   // akceptacja pliku
  final VoidCallback onPickAgain; // ponowne wybranie pliku

  const PreviewPDFPage({
    super.key,
    required this.filePath,
    required this.onBack,
    required this.onApprove,
    required this.onPickAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Podgląd PDF
            SizedBox(
              height: 500, // wysokość PDF
              width: 400,  // szerokość PDF
              child: PDFView(filePath: filePath),
            ),
            const SizedBox(height: 10),
            // Przyciskowa logika
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Cofnij do Home
                FloatingActionButton(
                  heroTag: "back",
                  onPressed: onBack,
                  backgroundColor: Colors.grey,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                const SizedBox(width: 20),
                // 2. Wybierz inny PDF
                FloatingActionButton(
                  heroTag: "pickAgain",
                  onPressed: onPickAgain,
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.attach_file, color: Colors.white),
                ),
                const SizedBox(width: 20),
                // 3. Akceptuj PDF
                FloatingActionButton(
                  heroTag: "approve",
                  onPressed: onApprove,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.check_circle, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
