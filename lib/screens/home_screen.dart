import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meus_quadrinhos/screens/detail_screen.dart';
import 'package:meus_quadrinhos/widgets/app_bar.dart';
import 'package:meus_quadrinhos/widgets/collection_card.dart';
import 'package:meus_quadrinhos/data/hive_boxes.dart';
import 'package:meus_quadrinhos/utils/config.dart';
import 'package:meus_quadrinhos/utils/helpers.dart';
import 'package:meus_quadrinhos/providers/filtered_items_provider.dart';

class HomePage extends StatefulWidget {
  static const String routeName = "/home";

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FilteredItemsProvider filteredItemsProvider;

  @override
  void initState() {
    super.initState();
    filteredItemsProvider =
        Provider.of<FilteredItemsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadItemsFromHive(filteredItemsProvider);
    });
    searchController.addListener(_filterItems);
    refreshItems(filteredItemsProvider);
  }

  @override
  void dispose() {
    collectionController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredItems = items.where((item) {
        final comic = item["comic"].toLowerCase();
        final description = item["description"].toLowerCase();
        return comic.contains(query) || description.contains(query);
      }).toList();
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await comicsBox.add(newItem);
    refreshItems(filteredItemsProvider);
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await comicsBox.put(itemKey, item);
    refreshItems(filteredItemsProvider);
  }

  Future<void> _deleteItem(int itemKey) async {
    await comicsBox.delete(itemKey);
    await issuesBox.delete(itemKey); // Delete associated issues
    refreshItems(filteredItemsProvider);
    _deletedItemMessage();
    selectedItem = null; // hides the delete icon from the app bar
  }

  Future<void> _deletedItemMessage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Quadrinho deletado da coleção."),
      ),
    );
  }

  void editItem() {
    // Implement edit functionality
    if (selectedItem != null) {
      _showForm(context, selectedItem!["key"]);
    }
  }

  void itemToDelete() {
    // Implement delete functionality
    if (selectedItem != null) {
      _deleteItem(selectedItem!["key"]); // Assuming each item has a unique 'id'
    }
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
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
          top: 15,
          left: 15,
          right: 15,
        ),
        child: SingleChildScrollView(
          child: Form(
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
                    if (formKey.currentState!.validate()) {
                      if (itemKey == null) {
                        _createItem({
                          "comic": collectionController.text.trim(),
                          "description": descriptionController.text.trim(),
                        });
                      } else {
                        _updateItem(itemKey, {
                          "comic": collectionController.text.trim(),
                          "description": descriptionController.text.trim(),
                        });
                      }
                      collectionController.clear();
                      descriptionController.clear();
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Salvar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(selectedItem: selectedItem),
      body: Consumer<FilteredItemsProvider>(
        builder: (context, provider, child) {
          final filteredItems = provider.filteredItems;
          return Column(
            children: [
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
                                      DetailPage(item: currentItem),
                                ),
                              );
                            },
                            onLongPress: () {
                              setState(() {
                                selectedItem = currentItem;
                              });
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
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
