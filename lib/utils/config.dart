import 'package:flutter/material.dart';

final TextEditingController collectionController = TextEditingController();
final TextEditingController descriptionController = TextEditingController();
final TextEditingController searchController = TextEditingController();

final formKey = GlobalKey<FormState>();

List<Map<String, dynamic>> items = [];
List<Map<String, dynamic>> filteredItems = [];
Map<String, dynamic>? selectedItem;
