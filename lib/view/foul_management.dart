part of '/common.dart';

class ViewFoul extends StatefulWidget {
  const ViewFoul({super.key});
  @override
  ViewFoulState createState() => ViewFoulState();
}

class ViewFoulState extends State<ViewFoul>
    with SingleTickerProviderStateMixin {
  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;
  bool get isPort => MediaQuery.of(context).orientation == Orientation.portrait;

  final TextEditingController ctrNumber = TextEditingController();
  final TextEditingController ctrHomeTeamName = TextEditingController();
  final TextEditingController ctrAwayTeamName = TextEditingController();

  final TStream<Map<String, int>> $mapOfHomeFoul = TStream<Map<String, int>>()
    ..sink$({});
  final TStream<Map<String, int>> $mapOfAwayFoul = TStream<Map<String, int>>()
    ..sink$({});

  late AnimationController animationController;
  late Animation<Color?> colorAnimation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(top: 0, right: 0, child: buildResetButton()),
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
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
        ],
      ),
    );
  }

  List<Widget> boards() {
    return [
      buildFoulBoard(isHome: true).expand(),
      const Padding(padding: EdgeInsets.all(5)),
      buildFoulBoard(isHome: false).expand(),
    ];
  }

  Widget buildResetButton() {
    return buildTextButton(
      child: const Icon(
        Icons.refresh,
        color: homeColor,
      ),
      onPressed: () {
        GSharedPreferences.remove('home');
        GSharedPreferences.remove('away');
        $mapOfAwayFoul.sink$({}); // TODO : 초기화
        $mapOfHomeFoul.sink$({}); // TODO : 초기화
      },
    );
  }

  Widget buildFoulBoard({required bool isHome}) {
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
                    labelText: isHome ? 'home' : 'away',
                  ),
                ),
              ).expand(),
              buildBasicButton(
                child: const Text(
                  'add',
                ),
                backgroundColor: isHome ? homeColor : awayColor,
                onPressed: () {
                  showManagementDialog(isHome, true);
                  ctrNumber.clear();
                },
              ),
              const VerticalDivider(),
              buildBasicButton(
                child: const Text(
                  'del',
                ),
                backgroundColor: isHome ? homeColor : awayColor,
                onPressed: () {
                  showManagementDialog(isHome, false);
                  ctrNumber.clear();
                },
              ),
              const VerticalDivider(),
              buildBasicButton(
                child: const Text(
                  'init',
                ),
                backgroundColor: isHome ? homeColor : awayColor,
                onPressed: () {
                  // TODO : 초기화
                  if (isHome) {
                    $mapOfHomeFoul.sink$({});
                    GSharedPreferences.setString('home', jsonEncode({}));
                  }
                  if (!isHome) {
                    $mapOfAwayFoul.sink$({});
                    GSharedPreferences.setString('away', jsonEncode({}));
                  }
                  ctrNumber.clear();
                },
              ),
            ],
          ).sizedBox(height: 40),
          const Padding(padding: EdgeInsets.all(8.0)),
          //
          TStreamBuilder(
            stream: isHome ? $mapOfHomeFoul.browse$ : $mapOfAwayFoul.browse$,
            builder: (context, Map<String, int> mapOfFoul) {
              return ListView.separated(
                separatorBuilder: (context, index) => const Divider(),
                itemCount: mapOfFoul.length,
                itemBuilder: (context, int index) {
                  List<int> convertKeys =
                      mapOfFoul.keys.toList().map((k) => int.parse(k)).toList();

                  convertKeys.sort();

                  String getNumber = convertKeys[index].toString();

                  int getFoulCount = mapOfFoul[getNumber]!;

                  return AnimatedBuilder(
                    animation: animationController,
                    builder: (context, child) {
                      return Container(
                        color: getFoulCount >= 3 ? colorAnimation.value : null,
                        child: Row(
                          children: [
                            Center(child: Text('${index + 1}')).expand(),
                            Center(
                              child: Text(
                                'No.$getNumber',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ).expand(flex: 3),
                            buildBasicButton(
                                child: const Text('-'),
                                backgroundColor: isHome ? homeColor : awayColor,
                                onPressed: () => removeFoul(
                                    isHome: isHome, number: getNumber)),
                            Center(child: Text('$getFoulCount')).expand(),
                            buildBasicButton(
                                child: const Text('+'),
                                backgroundColor: isHome ? homeColor : awayColor,
                                onPressed: () =>
                                    addFoul(isHome: isHome, number: getNumber)),
                          ],
                        ),
                      );
                    },
                  ).sizedBox(height: 30);
                },
              );
            },
          ).expand(),
        ],
      ),
    );
  }

  Future<void> showManagementDialog(bool isHome, bool isAdd) {
    return showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
          child: AlertDialog(
            title: isAdd
                ? const Text('추가하고자 하는 플레이어의 번호를 입력하세요')
                : const Text('지우고자 하는 플레이어의 번호를 입력해주세요.'),
            content: TextField(
              keyboardType: TextInputType.number,
              autofocus: true,
              controller: ctrNumber,
            ),
            actions: [
              isAdd ? buildAddButton(isHome) : buildRemoveButton(isHome),
            ],
          ),
        );
      },
    );
  }

  Widget buildAddButton(bool isHome) {
    return buildBasicButton(
        child: const Text('저장'), onPressed: () => savePlayer(isHome));
  }

  Widget buildRemoveButton(bool isHome) {
    return buildBasicButton(
        child: const Text('삭제'), onPressed: () => removePlayer(isHome));
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
      $mapOfHomeFoul.sink$({});
      return;
    }

    Map getHome = jsonDecode(GSharedPreferences.getString('home')!);

    Map<String, int> convertHome = getHome.map(
        (key, value) => MapEntry(key.toString(), int.parse(value.toString())));

    $mapOfHomeFoul.sink$(convertHome);
  }

  void initAway() {
    if (GSharedPreferences.getString('away') == null) {
      $mapOfAwayFoul.sink$({});
      return;
    }

    Map getAway = jsonDecode(GSharedPreferences.getString('away')!);

    Map<String, int> convertAway = getAway.map(
        (key, value) => MapEntry(key.toString(), int.parse(value.toString())));

    $mapOfAwayFoul.sink$(convertAway);
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

  void addFoul({required bool isHome, required String number}) {
    if (isHome) {
      Map<String, int> tmpMap = Map.from($mapOfHomeFoul.lastValue);
      tmpMap[number] = tmpMap[number]! + 1;
      $mapOfHomeFoul.sink$(tmpMap);

      GSharedPreferences.setString('home', jsonEncode(tmpMap));
      return;
    }
    //
    Map<String, int> tmpMap = Map.from($mapOfAwayFoul.lastValue);
    tmpMap[number] = tmpMap[number]! + 1;
    $mapOfAwayFoul.sink$(tmpMap);
    GSharedPreferences.setString('away', jsonEncode(tmpMap));
  }

  void removeFoul({required bool isHome, required String number}) {
    if (isHome) {
      Map<String, int> tmpMap = Map.from($mapOfHomeFoul.lastValue);
      tmpMap[number] = tmpMap[number]! - 1;
      if (tmpMap[number]! < 0) return;
      $mapOfHomeFoul.sink$(tmpMap);
      GSharedPreferences.setString('home', jsonEncode(tmpMap));
      return;
    }
    //
    Map<String, int> tmpMap = Map.from($mapOfAwayFoul.lastValue);
    tmpMap[number] = tmpMap[number]! - 1;
    if (tmpMap[number]! < 0) return;
    $mapOfAwayFoul.sink$(tmpMap);
    GSharedPreferences.setString('away', jsonEncode(tmpMap));
  }

  void savePlayer(bool isHome) {
    Map<String, int> tmpMap =
        Map.from(isHome ? $mapOfHomeFoul.lastValue : $mapOfAwayFoul.lastValue);
    if (tmpMap.keys.contains(int.parse(ctrNumber.text))) {
      print('이미 존재하는 번호입니다.');
      return;
    }
    tmpMap[ctrNumber.text] = 0;

    String teamDivision = isHome ? 'home' : 'away';

    GSharedPreferences.setString(teamDivision, jsonEncode(tmpMap));

    // stream sink$
    isHome ? $mapOfHomeFoul.sink$(tmpMap) : $mapOfAwayFoul.sink$(tmpMap);

    ctrNumber.clear();
    Navigator.pop(context);
  }

  void removePlayer(bool isHome) {
    Map<String, int> tmpMap =
        Map.from(isHome ? $mapOfHomeFoul.lastValue : $mapOfAwayFoul.lastValue);
    if (!tmpMap.keys.contains(ctrNumber.text)) {
      print('존재하지 않는 번호입니다.');
      return;
    }

    tmpMap.remove(ctrNumber.text);
    isHome ? $mapOfHomeFoul.sink$(tmpMap) : $mapOfAwayFoul.sink$(tmpMap);

    String teamDivision = isHome ? 'home' : 'away';

    GSharedPreferences.setString(teamDivision, jsonEncode(tmpMap));

    ctrNumber.clear();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
