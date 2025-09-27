import "package:appka/config/pages_route.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

enum MenuActions { profileSettiings, logout }

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
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
            ),
            onPressed: (){
              Navigator.of(ctx).pop();
              context.push(PagesRoute.loginPage.path);
            },
            child: const Text("Wyloguj"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Home"),
        actions:[
          PopupMenuButton<MenuActions>(
            onSelected: (value) {
              switch (value) {
                case MenuActions.profileSettiings:
                  context.push(PagesRoute.profilePage.path);
                  break;
                case MenuActions.logout:
                  _confirmLogout(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuActions>>[
              const PopupMenuItem<MenuActions>(
                value: MenuActions.profileSettiings,
                child: Text('Ustawienia profilu')
              ),
              const PopupMenuItem<MenuActions>(
                value: MenuActions.logout,
                child: Text('Wyloguj się')
              ),
            ]
          )
        ]
      ),
    );
  }
}
