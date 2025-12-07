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

  late final TextEditingController firstCtrl;
  late final TextEditingController lastCtrl;
  late final TextEditingController emailCtrl;

  @override
  void initState() {
    super.initState();

    final profileState = context.read<ProfileCubit>().state;

    if (profileState is ProfileUserLoaded) {
      firstCtrl = TextEditingController(text: profileState.firstName);
      lastCtrl = TextEditingController(text: profileState.lastName);
      emailCtrl = TextEditingController(text: profileState.username);
    } else {
      firstCtrl = TextEditingController();
      lastCtrl = TextEditingController();
      emailCtrl = TextEditingController();

      context.read<ProfileCubit>().fetchUser();
    }
  }

  @override
  void dispose() {
    firstCtrl.dispose();
    lastCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: const Text("Edycja profilu"),
        elevation: 0,
      ),

      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccess) {
            // odśwież profil po edycji
            context.read<ProfileCubit>().fetchUser();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Zapisano zmiany")),
            );
            context.pop();
          }
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? "Błąd zapisu")),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _field(
                    controller: firstCtrl,
                    label: "Imię",
                    icon: Icons.person,
                    validator: (v) => v == null || v.isEmpty ? "Wpisz imię" : null,
                  ),
                  const SizedBox(height: 20),

                  _field(
                    controller: lastCtrl,
                    label: "Nazwisko",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  _field(
                    controller: emailCtrl,
                    label: "Email",
                    icon: Icons.email,
                    keyboard: TextInputType.emailAddress,
                    validator: (v) =>
                    v != null && v.contains("@") ? null : "Wpisz poprawny email",
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<ProfileCubit>().updateUser(
                            firstName: firstCtrl.text,
                            lastName: lastCtrl.text,
                            username: emailCtrl.text,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white
                      ),
                      child: const Text(
                        "Zapisz dane",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
