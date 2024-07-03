import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key, required this.selectedItem});

  final Map<String, dynamic>? selectedItem;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        "Meus Quadrinhos",
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      titleSpacing: 50,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: selectedItem != null
          ? [
              IconButton(
                // Edit item
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
              IconButton(
                // Item to delete
                icon: const Icon(Icons.delete),
                onPressed: () {},
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
