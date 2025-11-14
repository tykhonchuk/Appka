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
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () async {
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

              if (confirm == true) {
                final docCubit = context.read<DocumentCubit>();
                await docCubit.deleteDocument(doc['id'], userFirstName, userLastName);
                onDelete(); // jeśli masz callback do odświeżenia listy
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Dokument został usunięty")),
                );
              }
            },
          ),
        );
      },
    );
  }
}
