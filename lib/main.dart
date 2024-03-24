import 'package:basket_ball/common.dart';
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
      'home': (context) => const ViewHome(),
      // 'foul': (context) => const ViewFoul(),
    };

    return MaterialApp(
      title: 'BasketBall',
      theme: ThemeData(
        // colorScheme:
        //     ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: false,
      ),
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
