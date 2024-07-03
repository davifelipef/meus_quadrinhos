import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meus_quadrinhos/screens/detail_screen.dart';
import 'package:meus_quadrinhos/widgets/collection_card.dart';
import 'package:meus_quadrinhos/utils/config.dart';
//import 'package:meus_quadrinhos/utils/helpers.dart';
import 'package:meus_quadrinhos/providers/filtered_items_provider.dart';

class CollectionGrid extends StatelessWidget {
  const CollectionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FilteredItemsProvider>(
      builder: (context, provider, child) {
        final filteredItems = provider.filteredItems;
        return Column(children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Pesquisar seus quadrinhos",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24.0)),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onTap:
                  () {}, // Needed to prevent GestureDetector from detecting tap on TextField
            ),
          ),
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      "Nada para ver ainda.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    primary: false,
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (_, index) {
                      final currentItem = filteredItems[index];
                      final isSelected = selectedItem == currentItem;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailScreen(item: currentItem),
                            ),
                          );
                        },
                        onLongPress: () {
                          selectedItem = currentItem;
                        },
                        child: Card(
                          color: isSelected
                              ? Colors.blue.shade200
                              : Colors.blue.shade100,
                          margin: const EdgeInsets.all(5),
                          elevation: 3,
                          child: CollectionCard(currentItem: currentItem),
                        ),
                      );
                    }),
          ),
        ]);
      },
    );
  }
}
