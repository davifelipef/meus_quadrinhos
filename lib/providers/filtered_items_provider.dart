import 'package:flutter/material.dart';

class FilteredItemsProvider extends ChangeNotifier {
  List<dynamic> _filteredItems = [];

  List<dynamic> get filteredItems => _filteredItems;

  void updateFilteredData(List<dynamic> newData) {
    _filteredItems = newData;
    notifyListeners(); // Notify listeners about the change
  }
}
