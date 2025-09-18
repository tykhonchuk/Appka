import "package:appka/config/pages_route.dart";
import "package:appka/cubit/login_cubit.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (_) => LoginCubit(),
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            context.go(PagesRoute.homePage.path);
          } else if (state is LoginError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? "Błąd logowania!")),
            );
          }
        },
        child: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state){
            final cubit = context.read<LoginCubit>();

            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text("Login"),
              ),
              body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: "Login",
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
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: (){
                        cubit.loginUser(
                          _usernameController.text,
                          _passwordController.text
                        );
                      },
                      child: const Text("Zaloguj się"),
                    ),
                  ],
                )
              ),
            );
          },
        ),
      ),
    );
  }
}
