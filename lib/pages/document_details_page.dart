import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  Widget _buildFilePreview() {
    final fileUrl = document['file_url'] ?? '';
    if (fileUrl.isEmpty) return const SizedBox();

    final fileType = document['file_type'] ?? '';
    if (fileType.contains('jpg') || fileType.contains('png')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Image.network(
            fileUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Text("Nie udało się wczytać obrazka"));
            },
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          // Możesz np. otworzyć PDF w przeglądarce lub w pakiecie PDF viewer
          // launchUrl(Uri.parse(fileUrl));
        },
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.redAccent),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf, size: 50, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                "PDF Dokument",
                style: TextStyle(fontSize: 18, color: Colors.redAccent),
              ),
            ],
          ),
        ),
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
            _buildFilePreview(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text("Edytuj"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white
                  ),
                  onPressed: () {
                    // Tutaj logika przejścia do edycji dokumentu
                    // np. context.push(PagesRoute.editDocumentPage.path, extra: document);
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text("Usuń"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                      foregroundColor: Colors.white
                  ),
                  onPressed: () {
                    _handleDelete(context);
                  }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
