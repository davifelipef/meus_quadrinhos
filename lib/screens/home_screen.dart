import 'package:flutter/material.dart';
import 'package:meus_quadrinhos/widgets/add_collection_button.dart';
import 'package:meus_quadrinhos/widgets/collection_grid.dart';
import 'package:provider/provider.dart';
import 'package:meus_quadrinhos/widgets/app_bar.dart';
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
  @override
  void initState() {
    super.initState();
    filteredItemsProvider =
        Provider.of<FilteredItemsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadItemsFromHive(filteredItemsProvider);
      refreshItems(filteredItemsProvider);
    });
    searchController.addListener(filterItems);
  }

  @override
  void dispose() {
    collectionController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        clearSearch();
      },
      child: Scaffold(
        appBar: AppBarWidget(selectedItem: selectedItem),
        body: const CollectionGrid(),
        floatingActionButton: AddCollectionButton(
          filteredItemsProvider: filteredItemsProvider,
        ),
      ),
    );
  }
}
