import "package:flutter/material.dart";

class AddDocumentPage extends StatelessWidget {
  const AddDocumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dodaj dokument"),
      ),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: "Tytuł",
            ),
          ),
          TextField(
            decoration: const InputDecoration(
              labelText: "Opis",
            ),
          ),
          ElevatedButton(
            onPressed: (){},
            child: const Text("Dodaj dokument")
          )
        ],
      ),
    );
  }
}
