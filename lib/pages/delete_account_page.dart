import "package:appka/config/pages_route.dart";
import "package:appka/cubit/profile_cubit.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";

class DeleteAccountPage extends StatelessWidget {
  const DeleteAccountPage({super.key});

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Potwierdzenie"),
        content: const Text("Czy na pewno chcesz usunąć konto?\nTej operacji nie można cofnąć!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Anuluj"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<ProfileCubit>().deleteAccount();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Konto zostało pomyślnie usunięte."),
                  backgroundColor: Colors.redAccent,
                  duration: Duration(seconds: 2),
                ),
              );
                context.go(PagesRoute.welcomePage.path);
            },
            child: const Text("Usuń"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Usuń konto")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 40),
            const SizedBox(height: 16),
            const Text(
              "Uwaga!\nUsunięcie konta spowoduje trwałą utratę wszystkich danych.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 48),
                foregroundColor: Colors.white,
              ),
              onPressed: () => _showConfirmDialog(context),
              child: const Text("Usuń konto"),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text("Anuluj"),
            ),
          ],
        ),
      ),
    );
  }
}

