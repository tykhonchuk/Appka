import 'package:flutter/material.dart';

class DocumentsFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedType;
  final List<String> availableTypes;
  final Function(String) onTypeChanged;

  const DocumentsFilterBar({
    super.key,
    required this.searchController,
    required this.selectedType,
    required this.availableTypes,
    required this.onTypeChanged,
  });

  void _openFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Filtr dokumentów",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              ...availableTypes.map((type) {
                return ListTile(
                  title: Text(type),
                  trailing: type == selectedType
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    onTypeChanged(type);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // 🔍 WYSZUKIWANIE — 85% szerokości
          Expanded(
            flex: 5,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Wyszukaj dokument...",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ⚙️ IKONA FILTRA — 15%
          InkWell(
            onTap: () => _openFilterMenu(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.filter_list, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}
