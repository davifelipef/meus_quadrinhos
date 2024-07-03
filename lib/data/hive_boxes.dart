import 'package:hive_flutter/hive_flutter.dart';

final Box<Map> comicsBox = Hive.box<Map>('comics_box');
final Box<dynamic> issuesBox = Hive.box('issues');
