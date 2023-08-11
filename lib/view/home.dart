part of '/common.dart';

class ViewHome extends StatefulWidget {
  const ViewHome({super.key});
  @override
  ViewHomeState createState() => ViewHomeState();
}

class ViewHomeState extends State<ViewHome> {
  PageController ctrPage = PageController();

  TStream<int> $selectedIndex = TStream<int>()..sink$(0);

  final List<Widget> pages = [
    const ViewOperationBoard(),
    const ViewFoul(),
  ];

  final List<String> titles = [
    '작전판',
    '파울관리',
  ];

  @override
  Widget build(BuildContext context) {
    return TStreamBuilder(
        stream: $selectedIndex.browse$,
        builder: (context, int selectedIndex) {
          return Scaffold(
            appBar: AppBar(
              toolbarHeight: kToolbarHeight,
              backgroundColor: homeColor,
              title: Text(titles[$selectedIndex.lastValue]),
            ),
            drawer: Drawer(
              backgroundColor: homeColor,
              child: ListView(
                children: [
                  DrawerHeader(
                      child: Text(
                    'basketBall',
                    style: const TextStyle(color: Colors.white),
                  )),
                  ListTile(
                    title: Text(
                      '작전판',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      $selectedIndex.sink$(0);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text(
                      '파울관리',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      $selectedIndex.sink$(1);
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
            body: PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: ctrPage,
              itemBuilder: (context, index) {
                return pages[selectedIndex];
              },
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }
}
