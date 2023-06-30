part of '/common.dart';

class ViewSplash extends StatefulWidget {
  const ViewSplash({super.key});

  @override
  ViewSplashState createState() => ViewSplashState();
}

class ViewSplashState extends State<ViewSplash>
    with SingleTickerProviderStateMixin {
  final TStream<bool> $splash = TStream<bool>();
  final int splashDuration = 20000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TStreamBuilder(
        stream: $splash.browse$,
        builder: (context, bool splash) {
          return AnimatedOpacity(
            opacity: splash ? 1 : 0,
            duration: Duration(milliseconds: splashDuration),
            child: Container(
              color: Colors.blue,
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    $splash.sink$(true);
    // $splash.sink$(false);
    await Navigator.pushNamed(context, 'foul');
  }
}
