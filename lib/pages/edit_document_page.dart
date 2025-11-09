import "package:appka/config/pages_route.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

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
    dateController = TextEditingController(text: widget.initialData?["visit_date"]?? "");
    diagnosisController = TextEditingController(text: widget.initialData?["diagnosis"] ?? "");
    recommendationsController = TextEditingController(text: widget.initialData?["recommendations"] ?? "");
    doctorController = TextEditingController(text: widget.initialData?["doctor_name"] ?? "");
    docTypeController = TextEditingController(text: widget.initialData?["document_type"] ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edycja dokumentu")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: "Imię"),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: "Nazwisko"),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: "Data wizyty"),
              ),
              TextField(
                controller: diagnosisController,
                decoration: const InputDecoration(labelText: "Rozpoznanie"),
              ),
              TextField(
                controller: recommendationsController,
                decoration: const InputDecoration(labelText: "Zalecenia"),
              ),
              TextField(
                controller: doctorController,
                decoration: const InputDecoration(labelText: "Lekarz"),
              ),
              TextField(
                controller: docTypeController,
                decoration: const InputDecoration(labelText: "Rodzaj dokumentu"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.push(PagesRoute.homePage.path);
                },
                child: const Text("Zapisz"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
