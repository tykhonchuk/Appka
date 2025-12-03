import "package:appka/config/pages_route.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class DocumentsList extends StatelessWidget {
  final String userFirstName;
  final String userLastName;
  final List<Map<String, dynamic>> documents;
  final VoidCallback onDelete;

  const DocumentsList({
    required this.userFirstName,
    required this.userLastName,
    required this.documents,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const Center(child: Text("Brak dokumentów"));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
      itemCount: documents.length,
      itemBuilder: (_, index) {
        final doc = documents[index];
        final fileType = (doc['file_type'] ?? '').toString().toLowerCase();

        return ListTile(
          leading: fileType.contains('jpg') || fileType.contains('png')
              ? const Icon(Icons.image, color: Colors.blueAccent, size: 30)
              : const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 30),
          title: Text(
            "${doc['document_type'] ?? 'Dokument'} – ${doc['visit_date'] ?? '-'}",
          ),
          subtitle: Text("Lekarz: ${doc['doctor_name'] ?? '-'}"),
          onTap: () async {
            // ⬇ przechodzimy do szczegółów i czekamy na wynik
            final deleted = await context.push<bool>(
              PagesRoute.documentDetailsPage.path,
              extra: doc,
            );

            // jeśli na ekranie szczegółów dokument został usunięty
            if (deleted == true) {
              // przeładuj listę w HomeTab (np. _loadUserDocuments)
              onDelete();

              // opcjonalny komunikat
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Dokument został usunięty")),
              );
            }
          },
        );
      },
    );
  }
}
