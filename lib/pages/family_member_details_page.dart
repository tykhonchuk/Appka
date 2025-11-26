import 'package:flutter/material.dart';

class MemberDetailPage extends StatelessWidget {
  final Map<String, dynamic> member;
  const MemberDetailPage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${member['first_name']} ${member['last_name']}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Imię i nazwisko: ${member['first_name']} ${member['last_name']}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              "Dokumenty: ${member['documents_count']}",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            // tutaj możesz dodać listę dokumentów jeśli masz szczegóły
          ],
        ),
      ),
    );
  }
}
