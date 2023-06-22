import 'package:faul_management/common.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  await init();
  runApp(const MyApp());
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  GSharedPreferences = await SharedPreferences.getInstance();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, Widget Function(BuildContext)> routes = {
      '/': (context) => const ViewFaulManagement(),
    };

    return MaterialApp(
      title: 'faul_management',
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //       seedColor: const Color.fromARGB(255, 83, 27, 27)),
      // useMaterial3: true,
      // ),
      routes: routes,
    );
  }
}
