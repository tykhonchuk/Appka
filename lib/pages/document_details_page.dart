import 'dart:io';

import 'package:flutter/material.dart';

class DocumentDetailsPage extends StatelessWidget {
  final Map<String, dynamic> document;

  const DocumentDetailsPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Szczegóły dokumentu")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Imię: ${document['patient_first_name'] ?? '-'}"),
            Text("Nazwisko: ${document['patient_last_name'] ?? '-'}"),
            Text("Data wizyty: ${document['visit_date'] ?? '-'}"),
            Text("Rozpoznanie: ${document['diagnosis'] ?? '-'}"),
            Text("Zalecenia: ${document['recommendations'] ?? '-'}"),
            Text("Lekarz: ${document['doctor_name'] ?? '-'}"),
            Text("Rodzaj dokumentu: ${document['document_type'] ?? '-'}"),
            const SizedBox(height: 20),
            if ((document['filepath'] ?? '').isNotEmpty)
              document['file_type'].toString().contains('jpg') ||
                  document['file_type'].toString().contains('png')
                  ? Image.file(
                File(document['filepath']),
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.picture_as_pdf, size: 100, color: Colors.redAccent),
          ],
        ),
      ),
    );
  }
}
