import 'package:flutter/material.dart';
import 'package:meus_quadrinhos/providers/filtered_items_provider.dart';
import 'package:meus_quadrinhos/utils/helpers.dart';

class AddCollectionButton extends StatelessWidget {
  const AddCollectionButton({super.key, required this.filteredItemsProvider});

  final FilteredItemsProvider filteredItemsProvider;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showForm(context, null, filteredItemsProvider),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }
}
