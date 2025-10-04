import "package:appka/config/pages_route.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

enum MenuActions { profileSettings, logout }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> items = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Home"),
        actions: [
          PopupMenuButton<MenuActions>(
            onSelected: (value) {
              switch (value) {
                case MenuActions.profileSettings:
                  context.push(PagesRoute.profilePage.path);
                  break;
                case MenuActions.logout:
                  _confirmLogout(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<MenuActions>>[
              const PopupMenuItem<MenuActions>(
                value: MenuActions.profileSettings,
                child: Text('Ustawienia profilu'),
              ),
              const PopupMenuItem<MenuActions>(
                value: MenuActions.logout,
                child: Text('Wyloguj się'),
              ),
            ],
          )
        ],
      ),
      body: items.isNotEmpty
          ? ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: const Icon(Icons.description),
            title: Text(items[index]),
          );
        },
      )
          : const Center(
        child: Text(
          'Brak dokumentów',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(PagesRoute.addDocumentPage.path);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
