import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meus_quadrinhos/utils/config.dart';
import 'package:meus_quadrinhos/data/hive_boxes.dart';
import 'package:meus_quadrinhos/providers/filtered_items_provider.dart';

Future<List<dynamic>> refreshItems(FilteredItemsProvider provider) async {
  final data = comicsBox.keys.map((key) {
    final item = (comicsBox.get(key) as Map).cast<String, dynamic>();
    return {
      "key": key,
      "comic": item["comic"],
      "description": item["description"],
      "issuesKey": key, // Use the same key for issues
    };
  }).toList();

  data.sort((a, b) => (a["comic"] as String).compareTo(b["comic"] as String));

  items = data;
  filteredItems = items;

  provider.updateFilteredData(filteredItems);

  return filteredItems;
}

// Load the events from the Hive
Future<void> loadItemsFromHive(FilteredItemsProvider provider) async {
  try {
    final box = Hive.box<Map<dynamic, dynamic>>('comics_box');
    items = box.values.map((item) {
      return item.cast<String, dynamic>();
    }).toList();

    await refreshItems(provider);
  } catch (e) {
    if (kDebugMode) {
      print("Error loading events from Hive: $e");
    }
  }
}

// Creates a new item
Future<void> createItem(Map<String, dynamic> newItem, VoidCallback onComplete,
    FilteredItemsProvider provider) async {
  try {
    await comicsBox.add(newItem);

    onComplete(); // Notify UI
  } catch (e) {
    if (kDebugMode) {
      print("Error creating item: $e");
    }
  }
}

// Update an existing item
Future<void> updateItem(int itemKey, Map<String, dynamic> item,
    FilteredItemsProvider provider) async {
  await comicsBox.put(itemKey, item);
  await refreshItems(provider); // Updates the UI and notifies listeners
}

// Delete an existing item
Future<void> deleteItem(int itemKey, FilteredItemsProvider provider) async {
  await comicsBox.delete(itemKey);
  await issuesBox.delete(itemKey);
  selectedItem = null;
  await refreshItems(provider); // Updates the UI and notifies listeners
}

void filterItems() {
  final query = searchController.text.toLowerCase();
  final filteredList = items.where((item) {
    final comic = item["comic"].toLowerCase();
    final description = item["description"].toLowerCase();
    return comic.contains(query) || description.contains(query);
  }).toList();

  filteredItemsProvider.updateFilteredData(filteredList);
}

void clearSearch() {
  searchController.clear();
  filteredItemsProvider.updateFilteredData(items);
}

void showForm(
    BuildContext ctx, int? itemKey, FilteredItemsProvider provider) async {
  if (itemKey != null) {
    final existingItem =
        items.firstWhere((element) => element["key"] == itemKey);
    collectionController.text = existingItem["comic"];
    descriptionController.text = existingItem["description"];
  } else {
    collectionController.clear();
    descriptionController.clear();
  }

  showModalBottomSheet(
    context: ctx,
    builder: (_) => Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
        top: 10,
        left: 15,
        right: 15,
      ),
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: collectionController,
                  decoration:
                      const InputDecoration(hintText: "Nome da coleção"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Por favor, insira o nome da coleção";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration:
                      const InputDecoration(hintText: "Descrição da coleção"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Por favor, insira a descrição da coleção";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final newEvent = {
                        "comic": collectionController.text.trim(),
                        "description": descriptionController.text.trim(),
                      };
                      if (itemKey == null) {
                        await createItem(newEvent, () async {
                          await refreshItems(provider);
                        }, provider);
                      } else {
                        final updatedEvent = {
                          "key": itemKey,
                          "comic": collectionController.text.trim(),
                          "description": descriptionController.text.trim(),
                        };
                        await updateItem(itemKey, updatedEvent, provider);
                      }
                      if (context.mounted) {
                        collectionController.clear();
                        descriptionController.clear();
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text("Salvar"),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
