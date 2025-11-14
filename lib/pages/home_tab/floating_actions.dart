import "package:flutter/material.dart";
import "package:flutter_speed_dial/flutter_speed_dial.dart";

class FloatingActions extends StatelessWidget {
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback onPickFile;

  const FloatingActions({required this.onPickCamera, required this.onPickGallery, required this.onPickFile, super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      children: [
        SpeedDialChild(child: const Icon(Icons.camera_alt), onTap: onPickCamera),
        SpeedDialChild(child: const Icon(Icons.photo_library), onTap: onPickGallery),
        SpeedDialChild(child: const Icon(Icons.attach_file), onTap: onPickFile),
      ],
    );
  }
}
