import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/detail_screen.dart';
import 'package:meus_quadrinhos/screens/home_screen.dart';
import 'package:meus_quadrinhos/providers/filtered_items_provider.dart';
import 'package:hive_flutter/adapters.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('comics_box');
  await Hive.openBox('issues');
  runApp(
    // With a multiprovider I can add more providers as needed
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) =>
                FilteredItemsProvider()), // Collections provider
        // Add more providers,
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, //disables the debug banner
        home: const HomePage(),
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
          ),
        ),
        routes: {
          HomePage.routeName: (context) => const HomePage(),
          DetailPage.routeName: (context) {
            final Map<String, dynamic> args = ModalRoute.of(context)!
                .settings
                .arguments as Map<String, dynamic>;
            return DetailPage(item: args['item']);
          },
        });
  }
}
