import 'package:flutter/material.dart';
import 'package:meus_quadrinhos/providers/filtered_items_provider.dart';

// Colors variables
const cblue = Colors.blue;

// Text controllers
final TextEditingController collectionController = TextEditingController();
final TextEditingController descriptionController = TextEditingController();
final TextEditingController searchController = TextEditingController();

// Global form key
final formKey = GlobalKey<FormState>();

// Item collection variables
List<Map<String, dynamic>> items = [];
List<Map<String, dynamic>> filteredItems = [];
Map<String, dynamic>? selectedItem;

// Provider variable
late FilteredItemsProvider filteredItemsProvider;
