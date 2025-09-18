import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "../config/pages_route.dart";

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("Welcome Page")),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              child: const Text("Zaloguj się"),
              onPressed: (){
                context.push(PagesRoute.loginPage.path);
              },
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: OutlinedButton(
              child: const Text("Zarejestruj się"),
              onPressed: (){
                context.push(PagesRoute.signupPage.path);
              },
            ),
          ),
        ]
      ),
    );
  }
}
