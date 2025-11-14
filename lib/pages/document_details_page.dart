import 'dart:io';
import 'package:flutter/material.dart';

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
    if ((document['filepath'] ?? '').isEmpty) {
      return const SizedBox();
    }

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
          child: Image.file(
            File(document['filepath']),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
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
          ],
        ),
      ),
    );
  }
}
