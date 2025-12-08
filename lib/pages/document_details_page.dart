import 'dart:io';
import 'package:appka/config/pages_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../cubit/document_cubit.dart';

class DocumentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> document;

  const DocumentDetailsPage({super.key, required this.document});

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(BuildContext context) {
    final fileUrl = document['file_url'] ?? '';
    if (fileUrl.isEmpty) return const SizedBox();

    final fileType = (document['file_type'] ?? '').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // ✅ Informacja, że plik jest załączony
        const Row(
          children: [
            Icon(Icons.attach_file, color: Colors.green),
            SizedBox(width: 6),
            Text(
              "Plik załączony",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ✅ Klikalny podgląd
        GestureDetector(
          onTap: () {
            _showFullScreenPreview(context, fileUrl, fileType);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  fileType.contains('pdf')
                      ? Icons.picture_as_pdf
                      : Icons.image,
                  color: Colors.blueAccent,
                  size: 40,
                ),
                const SizedBox(width: 12),
                const Text(
                  "Kliknij, aby otworzyć podgląd",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenPreview(
      BuildContext context,
      String fileUrl,
      String fileType,
      ) async {
    const contentFactor = 0.8; // 80% ekranu

    if (fileType.toLowerCase().contains('pdf')) {
      // --- PDF ---
      final response = await http.get(Uri.parse(fileUrl));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp_preview.pdf');
      await file.writeAsBytes(response.bodyBytes);

      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                // szare półprzezroczyste tło
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),

                // okno z PDF – 80% ekranu
                Center(
                  child: FractionallySizedBox(
                    widthFactor: contentFactor,
                    heightFactor: contentFactor,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: PDFView(filePath: file.path),
                    ),
                  ),
                ),

                // przycisk zamknięcia
                Positioned(
                  top: 40,
                  right: 20,
                  child: SafeArea(
                    child: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // --- OBRAZ ---
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),

                Center(
                  child: FractionallySizedBox(
                    widthFactor: contentFactor,
                    heightFactor: contentFactor,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: InteractiveViewer(
                        child: Image.network(
                          fileUrl,
                          fit: BoxFit.cover, // brak białych pasków
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 40,
                  right: 20,
                  child: SafeArea(
                    child: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }




  Future<void> _handleDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Usuń dokument"),
        content: const Text("Czy na pewno chcesz usunąć ten dokument?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Anuluj"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Usuń"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final docId = document['id'];
    if (docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Brak ID dokumentu – nie można usunąć")),
      );
      return;
    }

    final firstName = (document['patient_first_name'] ?? '').toString();
    final lastName = (document['patient_last_name'] ?? '').toString();

    try {
      await context
          .read<DocumentCubit>()
          .deleteDocument(docId as int, firstName, lastName);

      if (!context.mounted) return;

      // jeśli usunięcie się powiodło, DocumentCubit już odświeżył listę,
      // więc możemy wrócić do poprzedniego ekranu
      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dokument został usunięty")),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nie udało się usunąć dokumentu")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Szczegóły dokumentu"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("Imię", document['patient_first_name'] ?? '-'),
                    _buildInfoRow("Nazwisko", document['patient_last_name'] ?? '-'),
                    _buildInfoRow("Data wizyty", document['visit_date'] ?? '-'),
                    _buildInfoRow("Rozpoznanie", document['diagnosis'] ?? '-'),
                    _buildInfoRow("Zalecenia", document['recommendations'] ?? '-'),
                    _buildInfoRow("Lekarz", document['doctor_name'] ?? '-'),
                    _buildInfoRow("Rodzaj dokumentu", document['document_type'] ?? '-'),
                  ],
                ),
              ),
            ),
            _buildFilePreview(context),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text("Edytuj"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      // Tutaj logika przejścia do edycji dokumentu
                      context.push(PagesRoute.editDocumentPage.path, extra: document);
                    },
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text("Usuń"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    onPressed: () {
                      _handleDelete(context);
                    }
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
