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
  late Map<String, dynamic> _member;

  @override
  void initState() {
    super.initState();
    _member = Map<String, dynamic>.from(widget.member);
    _loadMemberDocuments();
  }

  Future<void> _loadMemberDocuments() async {
    final firstName = _member['first_name'] as String? ?? '';
    final lastName = _member['last_name'] as String? ?? '';

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
      await context.read<FamilyCubit>().deleteMember(id);

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

  void _onEditMember() async {
    final updated = await context.push<Map<String, dynamic>>(
      PagesRoute.editFamilyMemberPage.path,
      extra: _member,
    );
    if (updated != null && mounted) {
      setState(() {
        _member = updated;
      });
      _loadMemberDocuments();
    }
    // if (updated == true) {
    //   // odśwież dane konkretnego członka + dokumenty
    //   _loadMemberDocuments();
    //   context.read<FamilyCubit>().fetchFamilyMembers();
    // }
  }

  @override
  Widget build(BuildContext context) {
    final firstName = _member['first_name'] as String? ?? '';
    final lastName = _member['last_name'] as String? ?? '';
    final documentsCount = _member['documents_count'] ?? 0;

    String docsLabel;
    if (documentsCount == 0) {
      docsLabel = 'Brak dokumentów';
    } else if (documentsCount == 1) {
      docsLabel = '1 dokument';
    } else {
      docsLabel = '$documentsCount dokumenty';
    }

    return Scaffold(
      appBar: AppBar(
        // NIEBIESKI, ZAOKRĄGLONY APPBAR
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        // domyślna strzałka back
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // zamiast słowa "Podopieczny" – imię + liczba dokumentów
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$firstName $lastName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              docsLabel,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ],
        ),
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
          const SizedBox(height: 16),

          // Nagłówek sekcji dokumentów
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

          // 📄 Lista dokumentów z DocumentCubit
          Expanded(
            child: BlocBuilder<DocumentCubit, DocumentState>(
              builder: (context, state) {
                if (state is DocumentLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DocumentError) {
                  return Center(
                    child: Text(
                      state.message ?? 'Nie udało się załadować dokumentów',
                    ),
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

                      // 🔍 odczyt typu pliku
                      final fileType = (doc['file_type'] ?? '').toString().toLowerCase();
                      final isImage = fileType.contains('jpg') ||
                          fileType.contains('jpeg') ||
                          fileType.contains('png');
                      final isPdf = fileType.contains('pdf');

                      return ListTile(
                        leading: isImage
                            ? const Icon(Icons.image, color: Colors.blueAccent, size: 30)
                            : isPdf
                            ? const Icon(Icons.picture_as_pdf,
                            color: Colors.redAccent, size: 30)
                            : const Icon(Icons.insert_drive_file,
                            color: Colors.grey, size: 30),
                        title: Text(
                          date.isNotEmpty ? '$title – $date' : title,
                        ),
                        subtitle: doctor.isNotEmpty ? Text('Lekarz: $doctor') : null,
                        trailing: const Icon(Icons.chevron_right),
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
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
