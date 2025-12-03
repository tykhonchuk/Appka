import "dart:io";

import "package:appka/config/pages_route.dart";
import "package:appka/cubit/document_cubit.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

class DocumentsList extends StatelessWidget {
  final String userFirstName;
  final String userLastName;
  final List<Map<String, dynamic>> documents;
  final VoidCallback onDelete;

  const DocumentsList({required this.userFirstName, required this.userLastName, required this.documents, required this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) return const Center(child: Text("Brak dokumentów"));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
      itemCount: documents.length,
      itemBuilder: (_, index) {
        final doc = documents[index];
        final filepath = doc['filename'] as String?;
        final fileType = (doc['file_type'] ?? '').toString().toLowerCase();
        final isImage = fileType.contains('jpg') || fileType.contains('png');
        return ListTile(
          leading: (fileType.contains('jpg') || fileType.contains('png'))
              ? const Icon(Icons.image, color: Colors.blueAccent, size: 30) // miniatura dla obrazków
              : const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 30), // PDF

          title: Text("${doc['document_type'] ?? 'Dokument'} – ${doc['visit_date'] ?? '-'}"),
          subtitle: Text("Lekarz: ${doc['doctor_name'] ?? '-'}"),
          onTap: () {
            context.push(
              PagesRoute.documentDetailsPage.path,
              extra: doc,
            );
          },
        );
      },
    );
  }
}
