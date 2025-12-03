import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:appka/cubit/document_cubit.dart';
import 'package:appka/cubit/family_cubit.dart';
import 'package:appka/config/pages_route.dart';

class MemberDetailPage extends StatefulWidget {
  final Map<String, dynamic> member;

  const MemberDetailPage({
    super.key,
    required this.member,
  });

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadMemberDocuments();
  }

  Future<void> _loadMemberDocuments() async {
    final firstName = widget.member['first_name'] as String? ?? '';
    final lastName = widget.member['last_name'] as String? ?? '';

    await context
        .read<DocumentCubit>()
        .fetchDocumentsByPatientName(firstName, lastName);
  }

  void _onDeleteMember() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Usuń podopiecznego'),
        content: const Text(
          'Czy na pewno chcesz usunąć tego podopiecznego wraz z jego dokumentami?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Usuń',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final id = widget.member['id'] as int;
      //await context.read<FamilyCubit>().deleteMember(id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podopieczny został usunięty')),
      );
      context.pop(); // wróć do listy podopiecznych
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nie udało się usunąć podopiecznego')),
      );
    }
  }

  void _onEditMember() {
    // jeśli masz osobny ekran edycji – tu możesz zrobić push
    // np. context.push(PagesRoute.editFamilyMemberPage.path, extra: widget.member);
    // Na razie tylko placeholder:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edycja podopiecznego – do zaimplementowania')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstName = widget.member['first_name'] as String? ?? '';
    final lastName = widget.member['last_name'] as String? ?? '';
    final documentsCount = widget.member['documents_count'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('$firstName $lastName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _onEditMember,
            tooltip: 'Edytuj dane podopiecznego',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _onDeleteMember,
            tooltip: 'Usuń podopiecznego',
          ),
        ],
      ),
      body: Column(
        children: [
          // karta z danymi podopiecznego
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.blueAccent.shade100,
                      child: const Icon(Icons.person, size: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$firstName $lastName',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            documentsCount == 0
                                ? 'Brak dokumentów'
                                : documentsCount == 1
                                ? '1 dokument'
                                : '$documentsCount dokumentów',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Dokumenty podopiecznego',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // lista dokumentów z DocumentCubit
          Expanded(
            child: BlocBuilder<DocumentCubit, DocumentState>(
              builder: (context, state) {
                if (state is DocumentLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DocumentError) {
                  return Center(
                    child: Text(state.message ?? 'Nie udało się załadować dokumentów'),
                  );
                } else if (state is DocumentLoadedList) {
                  final docs = state.documents;
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Brak dokumentów dla tego podopiecznego'),
                    );
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final title = doc['document_type'] ?? 'Dokument medyczny';
                      final date = doc['visit_date'] ?? '';
                      final doctor = doc['doctor_name'] ?? '';

                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
                        title: Text('$title ${date.isNotEmpty ? ' – $date' : ''}'),
                        subtitle: doctor.isNotEmpty
                            ? Text('Lekarz: $doctor')
                            : null,
                        onTap: () {
                          // jeśli masz podgląd szczegółów dokumentu:
                          // context.push(
                          //   PagesRoute.documentDetailsPage.path,
                          //   extra: doc,
                          // );
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
