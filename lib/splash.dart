part of '/common.dart';

class ViewSplash extends StatefulWidget {
  const ViewSplash({super.key});

  @override
  ViewSplashState createState() => ViewSplashState();
}

class ViewSplashState extends State<ViewSplash>
    with SingleTickerProviderStateMixin {
  final TStream<bool> $splash = TStream<bool>();
  final int splashDuration = 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TStreamBuilder(
        stream: $splash.browse$,
        builder: (context, bool splash) {
          return AnimatedOpacity(
            opacity: splash ? 1 : 0,
            duration: Duration(milliseconds: splashDuration),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Center(
                child: Image.asset('images/basket_ball.png'),
              ),
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
    await wait(splashDuration);
    $splash.sink$(false);

    await wait(splashDuration);
    await Navigator.pushNamed(context, 'foul');
  }

  Future<void> wait(int? milliseconds) {
    milliseconds ??= 0;
    return Future.delayed(Duration(milliseconds: milliseconds));
  }
}
