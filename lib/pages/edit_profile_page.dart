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

    firstCtrl = TextEditingController();
    lastCtrl = TextEditingController();
    emailCtrl = TextEditingController();

    final cubit = context.read<ProfileCubit>();
    final state = cubit.state;

    // jeśli dane są już w pamięci – wypełnij od razu
    if (state is ProfileUserLoaded) {
      firstCtrl.text = state.firstName;
      lastCtrl.text = state.lastName;
      emailCtrl.text = state.username;
    } else {
      // jeśli nie – dociągnij z backendu
      cubit.fetchUser();
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
        title: const Text("Edycja profilu"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),

      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUserLoaded) {
            firstCtrl.text = state.firstName;
            lastCtrl.text = state.lastName;
            emailCtrl.text = state.username;
          }
          if (state is ProfileSuccess) {
            context.read<ProfileCubit>().fetchUser();

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Zapisano zmiany")),
            );
            context.pop(); // wróć do ProfilePage
          }

          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? "Błąd zapisu")),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
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
                    v != null && v.contains("@") ? null : "Podaj poprawny email",
                  ),
                  const SizedBox(height: 40),

                  InkWell(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ProfileCubit>().updateUser(
                          firstName: firstCtrl.text,
                          lastName: lastCtrl.text,
                          username: emailCtrl.text,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent.shade700,
                            Colors.blueAccent.shade400,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Zapisz zmiany",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
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
