import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meus_quadrinhos/utils/config.dart';
import 'package:meus_quadrinhos/data/hive_boxes.dart';
import 'package:meus_quadrinhos/providers/filtered_items_provider.dart';

Future<List<dynamic>> refreshItems(FilteredItemsProvider provider) async {
  final data = comicsBox.keys.map((key) {
    final item = comicsBox.get(key);
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
    final box = Hive.box<Map<String, dynamic>>('comics_box'); // Adjusted type
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
