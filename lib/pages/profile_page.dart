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
  String firstName = "";
  String lastName = "";
  String email = "john.doe@email.com";
  final int documents = 24;
  final int members = 6;
  final int mbUsed = 234;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final cubit = context.read<ProfileCubit>();
      await cubit.fetchUser(); // wywołuje request do backendu
      final state = cubit.state;
      if (state is ProfileUserLoaded) {
        setState(() {
          firstName = state.firstName;
          lastName = state.lastName;
          email = state.username;
        });
      }
    } catch (e) {
      // jeśli nie uda się pobrać imienia, możesz ustawić np. "Użytkownik"
      setState(() {
        firstName = "Użytkownik";
      });
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Potwierdzenie"),
        content: const Text("Czy na pewno chcesz się wylogować?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Anuluj"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push(PagesRoute.loginPage.path);
            },
            child: const Text("Wyloguj"),
          ),
        ],
      ),
    );
  }

  // Funkcja tworząca spójny przycisk
  Widget _buildProfileButton({
    required String text,
    required VoidCallback onPressed,
    // Color backgroundColor = Colors.blueAccent,
    Color foregroundColor = Colors.black,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          // backgroundColor: backgroundColor,
          // foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Hasło zostało zmienione!")),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? "Błąd zmiany hasła!")),
            );
          }
        },
        child: Scaffold(
          body: Column(
            children: [
              // Nagłówek
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent.shade700, Colors.blueAccent.shade100],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      offset: const Offset(0, 5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "$firstName $lastName",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Karty z danymi
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard("Dokumenty", documents.toString()),
                          _buildStatCard("Rodzina", members.toString()),
                          _buildStatCard("MB", mbUsed.toString()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Przyciski
              _buildProfileButton(
                text: "Edytuj profil",
                onPressed: () {
                  context.push(PagesRoute.editProfilePage.path);
                },
              ),
              _buildProfileButton(
                text: "Zmień hasło",
                foregroundColor: Colors.black,
                onPressed: () {
                  context.push(PagesRoute.changePasswordPage.path);
                },
              ),
              _buildProfileButton(
                text: "Usuń konto",
                // backgroundColor: Colors.red,
                onPressed: () {
                  context.push(PagesRoute.deletePage.path);
                },
              ),
              _buildProfileButton(
                text: "Wyloguj się",
                // backgroundColor: Colors.grey.shade700,
                onPressed: () {
                  _confirmLogout(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
