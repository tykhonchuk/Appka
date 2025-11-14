import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appka/cubit/profile_cubit.dart';
import 'package:go_router/go_router.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController emailCtrl;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileCubit>().state;

    if (state is ProfileUserLoaded) {
      firstNameCtrl = TextEditingController(text: state.firstName);
      lastNameCtrl = TextEditingController(text: state.lastName);
      emailCtrl = TextEditingController(text: state.username);
    } else {
      firstNameCtrl = TextEditingController();
      lastNameCtrl = TextEditingController();
      emailCtrl = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edytuj profil"),
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Zapisano zmiany")),
            );
            context.pop();  // powrót na ProfilePage
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? "Błąd zapisu")),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: firstNameCtrl,
                  decoration: const InputDecoration(labelText: "Imię"),
                  validator: (v) => v == null || v.isEmpty ? "Wpisz imię" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: lastNameCtrl,
                  decoration: const InputDecoration(labelText: "Nazwisko"),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (v) => v != null && v.contains("@")
                      ? null
                      : "Wpisz poprawny email",
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<ProfileCubit>().updateUser(
                        firstName: firstNameCtrl.text,
                        lastName: lastNameCtrl.text,
                        username: emailCtrl.text,
                      );
                    }
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
