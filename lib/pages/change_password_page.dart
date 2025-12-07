import "package:appka/cubit/profile_cubit.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _oldObscure = true;
  bool _newObscure = true;
  bool _confirmObscure = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    IconData icon = Icons.lock,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
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
    return BlocProvider(
      // jeśli masz ProfileCubit w MultiBlocProvider w main.dart,
      // możesz to usunąć i używać istniejącego Cubita
      create: (_) => ProfileCubit(),
      child: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Hasło zostało zmienione!")),
            );
            Navigator.of(context).pop();
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? "Błąd zmiany hasła!")),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            title: const Text(
              "Zmień hasło",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Zadbaj o bezpieczeństwo swojego konta",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Wprowadź aktualne hasło, a następnie nowe hasło dwa razy, aby potwierdzić zmianę.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 28),

                  _passwordField(
                    controller: _oldPasswordController,
                    label: "Aktualne hasło",
                    obscure: _oldObscure,
                    onToggle: () {
                      setState(() {
                        _oldObscure = !_oldObscure;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  _passwordField(
                    controller: _newPasswordController,
                    label: "Nowe hasło",
                    obscure: _newObscure,
                    onToggle: () {
                      setState(() {
                        _newObscure = !_newObscure;
                      });
                    },
                    icon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 20),

                  _passwordField(
                    controller: _confirmPasswordController,
                    label: "Potwierdź nowe hasło",
                    obscure: _confirmObscure,
                    onToggle: () {
                      setState(() {
                        _confirmObscure = !_confirmObscure;
                      });
                    },
                    icon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 30),

                  BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      final cubit = context.read<ProfileCubit>();

                      if (state is ProfileLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return InkWell(
                        onTap: () {
                          cubit.changePassword(
                            _oldPasswordController.text,
                            _newPasswordController.text,
                            _confirmPasswordController.text,
                          );
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
                              "Zmień hasło",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
