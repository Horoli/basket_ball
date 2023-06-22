part of '/common.dart';

class ViewFaulManagement extends StatefulWidget {
  const ViewFaulManagement({super.key});
  @override
  ViewFaulManagementState createState() => ViewFaulManagementState();
}

class ViewFaulManagementState extends State<ViewFaulManagement>
    with SingleTickerProviderStateMixin {
  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;
  bool get isPort => MediaQuery.of(context).orientation == Orientation.portrait;

  final TextEditingController ctrNumber = TextEditingController();
  final TextEditingController ctrHomeTeamName = TextEditingController();
  final TextEditingController ctrAwayTeamName = TextEditingController();

  final TStream<Map<String, int>> $mapOfHomeFaul = TStream<Map<String, int>>()
    ..sink$({});
  final TStream<Map<String, int>> $mapOfAwayFaul = TStream<Map<String, int>>()
    ..sink$({});

  late AnimationController animationController;
  late Animation<Color?> colorAnimation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('faul management'),
        backgroundColor: homeColor,
        automaticallyImplyLeading: false,
        actions: [
          buildTextButton(
            child: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              GSharedPreferences.clear();
              $mapOfAwayFaul.sink$({}); // TODO : 초기화
              $mapOfHomeFaul.sink$({}); // TODO : 초기화
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: width * 0.8,
              height: height * 0.8,
              child: !isPort
                  ? Row(children: boards())
                  : Column(children: boards()),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> boards() {
    return [
      buildFaulBoard(isHome: true).expand(),
      const Padding(padding: EdgeInsets.all(5)),
      buildFaulBoard(isHome: false).expand(),
    ];
  }

  Widget buildFaulBoard({required bool isHome}) {
    return buildBorderContainer(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: TextField(
                  controller: isHome
                      ? ctrHomeTeamName
                      : ctrAwayTeamName, // TODO : 팀이름 입력받는 컨트롤러
                  decoration: InputDecoration(
                    // border: OutlineInputBorder(),
                    labelText: isHome ? 'home' : 'away',
                  ),
                ),
              ).expand(),
              buildBasicButton(
                child: const Text(
                  'add player',
                ),
                backgroundColor: isHome ? homeColor : awayColor,
                onPressed: () {
                  showAddDialog(isHome);
                  ctrNumber.clear();
                },
              ).sizedBoxExpand.expand(),
              const Padding(padding: EdgeInsets.all(5)),
              buildBasicButton(
                child: const Text(
                  'del player',
                ),
                backgroundColor: isHome ? homeColor : awayColor,
                onPressed: () {
                  showDeleteDialog(isHome);
                  ctrNumber.clear();
                },
              ).sizedBoxExpand.expand(),
            ],
          ).sizedBox(height: kToolbarHeight),
          const Padding(padding: EdgeInsets.all(8.0)),
          //
          TStreamBuilder(
            stream: isHome ? $mapOfHomeFaul.browse$ : $mapOfAwayFaul.browse$,
            builder: (context, Map<String, int> mapOfFaul) {
              return ListView.separated(
                separatorBuilder: (context, index) => const Divider(),
                itemCount: mapOfFaul.length,
                itemBuilder: (context, int index) {
                  String getNumber = mapOfFaul.keys.toList()[index].toString();
                  int getFaulCount = mapOfFaul[getNumber]!;

                  return AnimatedBuilder(
                    animation: animationController,
                    builder: (context, child) {
                      return Container(
                        color: getFaulCount >= 3 ? colorAnimation.value : null,
                        child: Row(
                          children: [
                            Center(
                              child: Text(
                                '$getNumber',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ).expand(),
                            buildBasicButton(
                              child: const Text('-'),
                              backgroundColor: isHome ? homeColor : awayColor,
                              onPressed: () {
                                removeFaul(isHome: isHome, number: getNumber);
                              },
                            ).expand(),
                            Center(
                              child: Container(
                                child: Text('$getFaulCount'),
                              ),
                            ).expand(),
                            buildBasicButton(
                              child: const Text('+'),
                              backgroundColor: isHome ? homeColor : awayColor,
                              onPressed: () {
                                addFaul(isHome: isHome, number: getNumber);
                              },
                            ).expand(),
                          ],
                        ),
                      );
                    },
                  ).sizedBox(height: kToolbarHeight);
                },
              );
            },
          ).expand(),
        ],
      ),
    );
  }

  Future<void> showAddDialog(bool isHome) {
    return showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
          child: SingleChildScrollView(
            reverse: true,
            child: AlertDialog(
              title: const Text('추가하고자 하는 플레이어의 번호를 입력하세요'),
              content: TextField(
                keyboardType: TextInputType.number,
                autofocus: true,
                controller: ctrNumber,
              ),
              actions: [
                buildBasicButton(
                  child: const Text('저장'),
                  onPressed: () {
                    if (isHome) {
                      Map<String, int> tmpMap =
                          Map.from($mapOfHomeFaul.lastValue);
                      if (tmpMap.keys.contains(int.parse(ctrNumber.text))) {
                        print('이미 존재하는 번호입니다.');
                        return;
                      }
                      tmpMap[ctrNumber.text] = 0;
                      $mapOfHomeFaul.sink$(tmpMap);
                      GSharedPreferences.setString('home', jsonEncode(tmpMap));
                    }
                    //
                    if (!isHome) {
                      Map<String, int> tmpMap =
                          Map.from($mapOfAwayFaul.lastValue);

                      if (tmpMap.keys.contains(int.parse(ctrNumber.text))) {
                        print('이미 존재하는 번호입니다.');
                        return;
                      }
                      tmpMap[ctrNumber.text] = 0;
                      $mapOfAwayFaul.sink$(tmpMap);
                      GSharedPreferences.setString('away', jsonEncode(tmpMap));
                    }
                    ctrNumber.clear();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showDeleteDialog(bool isHome) {
    return showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
          child: SingleChildScrollView(
            child: Center(
              child: AlertDialog(
                title: const Text('지우고자 하는 플레이어의 번호를 입력해주세요.'),
                content: TextField(
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  controller: ctrNumber,
                ),
                actions: [
                  buildBasicButton(
                    child: const Text('삭제'),
                    onPressed: () {
                      if (isHome) {
                        Map<String, int> tmpMap =
                            Map.from($mapOfHomeFaul.lastValue);
                        if (!tmpMap.keys.contains(ctrNumber.text)) {
                          print('존재하지 않는 번호입니다.');
                          return;
                        }
                        tmpMap.remove(ctrNumber.text);
                        $mapOfHomeFaul.sink$(tmpMap);
                        GSharedPreferences.setString(
                            'home', jsonEncode(tmpMap));
                      }
                      //
                      if (!isHome) {
                        Map<String, int> tmpMap =
                            Map.from($mapOfAwayFaul.lastValue);
                        if (!tmpMap.keys.contains(ctrNumber.text)) {
                          print('존재하지 않는 번호입니다.');
                          return;
                        }

                        tmpMap.remove(ctrNumber.text);
                        $mapOfAwayFaul.sink$(tmpMap);
                        GSharedPreferences.setString(
                            'away', jsonEncode(tmpMap));
                      }
                      ctrNumber.clear();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    setAnimation();
    initHome();
    initAway();
  }

  void initHome() {
    if (GSharedPreferences.getString('home') == null) {
      $mapOfHomeFaul.sink$({});
      return;
    }

    Map getHome = jsonDecode(GSharedPreferences.getString('home')!);

    Map<String, int> convertHome = getHome.map(
        (key, value) => MapEntry(key.toString(), int.parse(value.toString())));

    $mapOfHomeFaul.sink$(convertHome);
  }

  void initAway() {
    if (GSharedPreferences.getString('away') == null) {
      $mapOfAwayFaul.sink$({});
      return;
    }

    Map getAway = jsonDecode(GSharedPreferences.getString('away')!);

    Map<String, int> convertAway = getAway.map(
        (key, value) => MapEntry(key.toString(), int.parse(value.toString())));

    $mapOfAwayFaul.sink$(convertAway);
  }

  void setAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // animationController.repeat(reverse: true);

    final CurvedAnimation curve =
        CurvedAnimation(parent: animationController, curve: Curves.linear);
    colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.red[200],
    ).animate(curve);

    colorAnimation.addStatusListener((status) {
      // Reverse the animation after it has been completed
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animationController.forward();
      }
      setState(() {});
    });
    // Remove this line if you want to start the animation later
    animationController.forward();
  }

  void addFaul({required bool isHome, required String number}) {
    if (isHome) {
      Map<String, int> tmpMap = Map.from($mapOfHomeFaul.lastValue);
      tmpMap[number] = tmpMap[number]! + 1;
      $mapOfHomeFaul.sink$(tmpMap);

      GSharedPreferences.setString('home', jsonEncode(tmpMap));
      return;
    }
    //
    Map<String, int> tmpMap = Map.from($mapOfAwayFaul.lastValue);
    tmpMap[number] = tmpMap[number]! + 1;
    $mapOfAwayFaul.sink$(tmpMap);
    GSharedPreferences.setString('away', jsonEncode(tmpMap));
  }

  void removeFaul({required bool isHome, required String number}) {
    if (isHome) {
      Map<String, int> tmpMap = Map.from($mapOfHomeFaul.lastValue);
      tmpMap[number] = tmpMap[number]! - 1;
      if (tmpMap[number]! < 0) return;
      $mapOfHomeFaul.sink$(tmpMap);
      GSharedPreferences.setString('home', jsonEncode(tmpMap));
      return;
    }
    //
    Map<String, int> tmpMap = Map.from($mapOfAwayFaul.lastValue);
    tmpMap[number] = tmpMap[number]! - 1;
    if (tmpMap[number]! < 0) return;
    $mapOfAwayFaul.sink$(tmpMap);
    GSharedPreferences.setString('away', jsonEncode(tmpMap));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
