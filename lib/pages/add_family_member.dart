import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appka/cubit/family_cubit.dart';

class AddFamilyMemberPage extends StatefulWidget {
  const AddFamilyMemberPage({super.key});

  @override
  State<AddFamilyMemberPage> createState() => _AddFamilyMemberPageState();
}

class _AddFamilyMemberPageState extends State<AddFamilyMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  void _saveMember() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<FamilyCubit>().addMember(
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
    );

    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Podopieczny został dodany")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔵 Gradient + zaokrąglone rogi jak w FamilyPage
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        title: const Text(
          "Dodaj podopiecznego",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Avatar jak w MemberDetailPage
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blueAccent.shade100,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ✏ Imię
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: "Imię",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? "Podaj imię" : null,
                    ),
                    const SizedBox(height: 16),

                    // ✏ Nazwisko
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: "Nazwisko",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) =>
                      value!.isEmpty ? "Podaj nazwisko" : null,
                    ),

                    const SizedBox(height: 30),

                    // 🔵 Niepełna szerokość, styl jak przycisków u Ciebie
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveMember,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Zapisz",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
