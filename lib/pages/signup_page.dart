import "package:appka/config/pages_route.dart";
import "package:appka/cubit/signup_cubit.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignupCubit(),
      child: BlocListener<SignupCubit, SignupState>(
        listener: (context, state){
          if (state is SignupSuccess){
            context.go(PagesRoute.accountCreatedPage.path);
            //redirect
          } else if (state is SignupError){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? "Błąd rejestracji!"))
            );
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            centerTitle: true,
            title: Text("Zarejestruj się"),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "E-mail",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Hasło",
                    border: OutlineInputBorder(),
                  )
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Potwierdź hasło",
                    border: OutlineInputBorder(),
                  )
                ),
                const SizedBox(height: 24),
                BlocBuilder<SignupCubit, SignupState>(
                  builder: (context, state) {
                    final cubit = context.read<SignupCubit>();
                    if (state is SignupLoading) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      onPressed: () {
                        cubit.registerUser(
                            _usernameController.text,
                            _passwordController.text,
                            _confirmPasswordController.text
                        );
                      },
                      child: const Text("Zarejestruj się"),
                    );
                  }
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}
