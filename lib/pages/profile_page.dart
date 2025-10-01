import "package:appka/config/pages_route.dart";
import "package:appka/cubit/profile_cubit.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state){
          if (state is ProfileSuccess){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Hasło zostało zmienione!"))
            );
          } else if (state is ProfileError){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? "Błąd zmiany hasła!"))
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Profile"),
          ),
          body: Column(
            children: [
              Center(
                child: ElevatedButton(
                  child: const Text("Zmień hasło"),
                  onPressed: (){
                    context.push(PagesRoute.changePasswordPage.path);
                  }
                ),
              ),
              Center(
                child: ElevatedButton(
                  child: const Text("Usuń konto"),
                  onPressed: (){
                    context.push(PagesRoute.deletePage.path);
                  }
                ),
              )
            ],
          )
        ),
      )
    );
  }
}
