import 'package:foul_management/common.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  await init();
  runApp(const AppRoot());
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  GSharedPreferences = await SharedPreferences.getInstance();
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, Widget Function(BuildContext)> routes = {
      '/': (context) => const ViewSplash(),
      'foul': (context) => const ViewFoulManagement(),
    };

    return MaterialApp(
      title: 'foul_management',

      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //       seedColor: const Color.fromARGB(255, 83, 27, 27)),
      // useMaterial3: true,
      // ),
      routes: routes,
    );
  }

  Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }
}
