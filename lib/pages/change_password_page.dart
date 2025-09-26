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
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_)=> ProfileCubit(),
      child: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state){
          if (state is ProfileSuccess){
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Hasło zostało zmienione!"))
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message ?? "Błąd zmiany hasła!"))
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text("Zmień hasło"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _oldPasswordController,
                  decoration: const InputDecoration(
                    labelText: "Hasło",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _newPasswordController,
                  decoration: const InputDecoration(
                    labelText: "Nowe hasło",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: "Potwierdź nowe hasło",
                    border: OutlineInputBorder(),
                  )
                ),
                const SizedBox(height: 24),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state){
                    final cubit = context.read<ProfileCubit>();
                    if (state is ProfileLoading) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      onPressed: (){
                        cubit.changePassword(
                          _oldPasswordController.text,
                          _newPasswordController.text,
                          _confirmPasswordController.text
                        );
                      },
                      child: const Text("Zmień hasło"),
                    );
                  },
                ),
              ]
            ),
          ),
        )
      )
    );
  }
}

