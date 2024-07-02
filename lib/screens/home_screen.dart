import 'package:flutter/material.dart';
//import 'package:meus_quadrinhos/widgets/drawer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meus_quadrinhos/screens/detail_screen.dart';

class HomePage extends StatefulWidget {
  static const String routeName = "/home";

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _collectionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  Map<String, dynamic>? _selectedItem;

  final _comicsBox = Hive.box("comics_box");
  final _issuesBox = Hive.box("issues");
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _refreshItems();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _collectionController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refreshItems() {
    final data = _comicsBox.keys.map((key) {
      final item = _comicsBox.get(key);
      return {
        "key": key,
        "comic": item["comic"],
        "description": item["description"],
        "issuesKey": key, // Use the same key for issues
      };
    }).toList();

    data.sort((a, b) => (a["comic"] as String).compareTo(b["comic"] as String));

    setState(() {
      _items = data;
      _filteredItems = _items;
    });
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _items.where((item) {
        final comic = item["comic"].toLowerCase();
        final description = item["description"].toLowerCase();
        return comic.contains(query) || description.contains(query);
      }).toList();
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _comicsBox.add(newItem);
    _refreshItems();
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _comicsBox.put(itemKey, item);
    _refreshItems();
  }

  Future<void> _deleteItem(int itemKey) async {
    await _comicsBox.delete(itemKey);
    await _issuesBox.delete(itemKey); // Delete associated issues
    _refreshItems();
    _deletedItemMessage();
    _selectedItem = null; // hides the delete icon from the app bar
  }

  Future<void> _deletedItemMessage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Quadrinho deletado da coleção."),
      ),
    );
  }

  void _editItem() {
    // Implement edit functionality
    if (_selectedItem != null) {
      _showForm(context, _selectedItem!["key"]);
    }
  }

  void _itemToDelete() {
    // Implement delete functionality
    if (_selectedItem != null) {
      _deleteItem(
          _selectedItem!["key"]); // Assuming each item has a unique 'id'
    }
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element["key"] == itemKey);
      _collectionController.text = existingItem["comic"];
      _descriptionController.text = existingItem["description"];
    } else {
      _collectionController.clear();
      _descriptionController.clear();
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
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _collectionController,
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
                  controller: _descriptionController,
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
                    if (_formKey.currentState!.validate()) {
                      if (itemKey == null) {
                        _createItem({
                          "comic": _collectionController.text.trim(),
                          "description": _descriptionController.text.trim(),
                        });
                      } else {
                        _updateItem(itemKey, {
                          "comic": _collectionController.text.trim(),
                          "description": _descriptionController.text.trim(),
                        });
                      }
                      _collectionController.clear();
                      _descriptionController.clear();
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
      appBar: AppBar(
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
        actions: _selectedItem != null
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editItem,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _itemToDelete,
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          SizedBox(
            width: 350,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: "Pesquisar seus quadrinhos",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24.0)),
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredItems.isEmpty
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
                    itemCount: _filteredItems.length,
                    itemBuilder: (_, index) {
                      final currentItem = _filteredItems[index];
                      final isSelected = _selectedItem == currentItem;
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
                            _selectedItem = currentItem;
                          });
                        },
                        child: Card(
                          color: isSelected
                              ? Colors.blue.shade200
                              : Colors.blue.shade100,
                          margin: const EdgeInsets.all(5),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentItem["comic"] ??
                                      "Erro ao retornar o quadrinho",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  currentItem["description"] ?? "",
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
