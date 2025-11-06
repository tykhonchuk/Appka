import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:appka/config/pages_route.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> items = [];

  void _pickImageFromCamera(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📸 Otwieranie aparatu...")),
    );
  }

  void _pickImageFromGallery(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🖼️ Otwieranie galerii...")),
    );
  }

  void _pickFile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📁 Wybieranie pliku...")),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == "profile") context.push(PagesRoute.profilePage.path);
              if (value == "logout") _confirmLogout(context);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "profile", child: Text("Ustawienia profilu")),
              PopupMenuItem(value: "logout", child: Text("Wyloguj się")),
            ],
          ),
        ],
      ),
      body: items.isNotEmpty
          ? ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, index) => ListTile(
          leading: const Icon(Icons.description),
          title: Text(items[index]),
        ),
      )
          : const Center(
        child: Text(
          "Brak dokumentów",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),

      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        spacing: 10,
        overlayOpacity: 0.4,
        overlayColor: Colors.black,
        curve: Curves.easeInOutCubic,
        childrenButtonSize: const Size(60, 60),
        elevation: 8,

        children: [
          SpeedDialChild(
            child: const Icon(Icons.camera_alt),
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.blueGrey.shade800,
            //label: "Zrób zdjęcie",
            //labelStyle: const TextStyle(fontSize: 16),
            onTap: () => _pickImageFromCamera(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.photo_library),
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.teal.shade700,
            //label: "Z galerii",
            //labelStyle: const TextStyle(fontSize: 16),
            onTap: () => _pickImageFromGallery(context),
          ),
          SpeedDialChild(
            child: const Icon(Icons.attach_file),
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.deepPurple.shade400,
            //label: "Z plików",
            labelStyle: const TextStyle(fontSize: 16),
            onTap: () => _pickFile(context),
          ),
        ],
      ),
    );
  }
}
