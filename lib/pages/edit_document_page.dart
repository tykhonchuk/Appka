import 'package:appka/config/pages_route.dart';
import 'package:appka/cubit/document_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditDocumentPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const EditDocumentPage({super.key, this.initialData});

  @override
  State<EditDocumentPage> createState() => _EditDocumentPageState();
}

class _EditDocumentPageState extends State<EditDocumentPage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController dateController;
  late TextEditingController diagnosisController;
  late TextEditingController recommendationsController;
  late TextEditingController doctorController;
  late TextEditingController docTypeController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.initialData?["patient_first_name"] ?? "");
    lastNameController = TextEditingController(text: widget.initialData?["patient_last_name"] ?? "");
    dateController = TextEditingController(text: widget.initialData?["visit_date"] ?? "");
    diagnosisController = TextEditingController(text: widget.initialData?["diagnosis"] ?? "");
    recommendationsController = TextEditingController(text: widget.initialData?["recommendations"] ?? "");
    doctorController = TextEditingController(text: widget.initialData?["doctor_name"] ?? "");
    docTypeController = TextEditingController(text: widget.initialData?["document_type"] ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentCubit, DocumentState>(
      listener: (context, state) {
        if (state is DocumentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Dokument dodany!")),
          );
          context.push(PagesRoute.homePage.path);
        } else if (state is DocumentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? "Błąd podczas dodawania dokumentu")),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Edycja dokumentu")),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(controller: firstNameController, decoration: const InputDecoration(labelText: "Imię")),
                TextField(controller: lastNameController, decoration: const InputDecoration(labelText: "Nazwisko")),
                TextField(controller: dateController, decoration: const InputDecoration(labelText: "Data wizyty")),
                TextField(controller: diagnosisController, decoration: const InputDecoration(labelText: "Rozpoznanie")),
                TextField(controller: recommendationsController, decoration: const InputDecoration(labelText: "Zalecenia")),
                TextField(controller: doctorController, decoration: const InputDecoration(labelText: "Lekarz")),
                TextField(controller: docTypeController, decoration: const InputDecoration(labelText: "Rodzaj dokumentu")),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<DocumentCubit>().addDocument({
                      'patient_first_name': firstNameController.text,
                      'patient_last_name': lastNameController.text,
                      'visit_date': dateController.text,
                      'diagnosis': diagnosisController.text,
                      'recommendations': recommendationsController.text,
                      'doctor_name': doctorController.text,
                      'document_type': docTypeController.text,
                    });
                  },
                  child: const Text("Zapisz"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
