import "package:flutter/material.dart";
import "package:flutter_pdfview/flutter_pdfview.dart";

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
            SizedBox(
              height: 500,
              width: 400,
              child: PDFView(filePath: filePath),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: "back",
                  onPressed: onBack,
                  backgroundColor: Colors.grey,
                  child: const Icon(Icons.close, color: Colors.white),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: "pickAgain",
                  onPressed: onPickAgain,
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.attach_file, color: Colors.white),
                ),
                const SizedBox(width: 20),
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
