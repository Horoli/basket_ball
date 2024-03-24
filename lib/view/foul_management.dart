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
  final TextEditingController ctrHomeTeamLabel = TextEditingController();
  final TextEditingController ctrAwayTeamLabel = TextEditingController();

  late AnimationController animationController;
  late Animation<Color?> colorAnimation;

  List<int> quarters = [1, 2, 3, 4];

  int currentQuarter = 1;

  late Team home;
  late Team away;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: width * 0.8,
              height: height * 0.8,
              child: Column(
                children: [
                  SizedBox(
                    height: kToolbarHeight,
                    child: Row(
                      children: List.generate(
                        quarters.length,
                        (index) =>
                            buildQuarterManagermentButton(index + 1).expand(),
                      ).toList(),
                    ),
                  ),
                  buildTeamBoard(team: home).expand(),
                  buildTeamBoard(team: away).expand(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    // return Scaffold(
    //   backgroundColor: Colors.white,
    //   resizeToAvoidBottomInset: false,
    //   body: Stack(
    //     children: [
    //       Positioned(top: 0, right: 0, child: buildResetButton()),
    //       GestureDetector(
    //         onTap: () => FocusScope.of(context).unfocus(),
    //         child: Center(
    //           child: SizedBox(
    //             width: width * 0.8,
    //             height: height * 0.8,
    //             child: !isPort
    //                 ? Row(children: boards())
    //                 : Column(children: boards()),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget buildTeamBoard({required Team team}) {
    return buildBorderContainer(
      child: Column(
        children: [
          buildManagementButtonTile(team: team)
              .sizedBox(height: kToolbarHeight),
          buildTeamPlayersTile(team: team).expand(),
          buildQuarterTile(team: team).sizedBox(height: kToolbarHeight),
        ],
      ),
    );
  }

  Widget buildQuarterTile({required Team team}) {
    return Row(
      children: List.generate(
        team.quarters.length,
        (index) => Container(
          child: Column(
            children: [
              Text('${team.quarters.keys.toList()[index]}Q').expand(),
              Text('${team.quarters.values.toList()[index]}').expand(),
            ],
          ).expand(),
        ),
      ),
    );
  }

  Widget buildManagementButtonTile({required Team team}) {
    return Row(
      children: [
        TextField(
          decoration: InputDecoration(helperText: team.division),
        ).expand(),
        const Padding(padding: EdgeInsets.all(4)),
        buildBasicButton(
          child: const Text(
            '추가',
          ),
          backgroundColor: team.division == 'home' ? COLOR_HOME : COLOR_AWAY,
          onPressed: () {
            setState(() {
              showPlayerManagementDialog(team: team);
              ctrNumber.clear();
            });
          },
        ),
        const Padding(padding: EdgeInsets.all(4)),
        buildBasicButton(
          child: const Text(
            '삭제',
          ),
          backgroundColor: team.division == 'home' ? COLOR_HOME : COLOR_AWAY,
          onPressed: () {
            setState(() {
              showPlayerManagementDialog(team: team, isAdd: false);
              ctrNumber.clear();
            });
          },
        ),
        const Padding(padding: EdgeInsets.all(4)),
        buildBasicButton(
          child: const Text(
            '초기화',
          ),
          backgroundColor: team.division == 'home' ? COLOR_HOME : COLOR_AWAY,
          onPressed: () async {
            setState(() {
              team.init();

              ctrNumber.clear();
            });
            await setSharedPreference(team);
          },
        ),
      ],
    );
  }

  Widget buildTeamPlayersTile({required Team team}) {
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      itemCount: team.players.length,
      itemBuilder: (context, int index) {
        List<int> convertKeys =
            team.players.keys.toList().map((k) => int.parse(k)).toList();

        convertKeys.sort();

        String getNumber = convertKeys[index].toString();

        int getFoulCount = team.players[getNumber]!;

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
                      backgroundColor:
                          team.division == 'home' ? COLOR_HOME : COLOR_AWAY,
                      onPressed: () async {
                        if (getFoulCount != 0) {
                          setState(() {
                            team.playerFoulControl(
                              isIncrease: false,
                              number: getNumber,
                            );

                            team.quaterFoulControl(
                              isIncrease: false,
                              quarter: currentQuarter,
                            );
                          });
                          await setSharedPreference(team);
                        }
                      }),
                  Center(child: Text('$getFoulCount')).expand(),
                  buildBasicButton(
                      child: const Text('+'),
                      backgroundColor:
                          team.division == 'home' ? COLOR_HOME : COLOR_AWAY,
                      onPressed: () async {
                        setState(() {
                          team.playerFoulControl(number: getNumber);
                          team.quaterFoulControl(quarter: currentQuarter);
                        });
                        await setSharedPreference(team);
                      }),
                ],
              ),
            );
          },
        ).sizedBox(height: 30);
      },
    );
  }

  Future<void> showPlayerManagementDialog({
    required Team team,
    bool isAdd = true,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
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
                isAdd ? buildDialogInSave(team) : buildDialogInRemove(team),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildDialogInSave(Team team) {
    return buildBasicButton(
        child: const Text('저장'),
        onPressed: () async {
          setState(() {
            team.setPlayer(number: ctrNumber.text);
          });
          await setSharedPreference(team);
          Navigator.pop(context);
        });
  }

  Widget buildDialogInRemove(Team team) {
    return buildBasicButton(
        child: const Text('삭제'),
        onPressed: () async {
          setState(() {
            team.removePlayer(number: ctrNumber.text);
          });
          await setSharedPreference(team);
          Navigator.pop(context);
        });
  }

  Widget buildQuarterManagermentButton(int quarter) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: buildBasicButton(
        child: Text('${quarter}쿼터'),
        backgroundColor: currentQuarter == quarter ? Colors.blue : Colors.grey,
        onPressed: () {
          setState(() {
            currentQuarter = quarter;
          });
        },
      ),
    );
  }

  // Widget buildSetSharedPreferenceButton({
  //   required Widget child,
  //   required Function() onPressed,
  // }) {
  //   return ElevatedButton(
  //     child: child,
  //     onPressed: () {
  //       onPressed;
  //     },
  //   );
  // }

  @override
  void initState() {
    setAnimation();
    initHome();
    initAway();
    super.initState();
  }

  Future<void> setSharedPreference(Team team) async {
    String json = jsonEncode(team.map);
    await GSharedPreferences.setString(team.division, json);
  }

  void initHome() {
    if (GSharedPreferences.getString('home') == null) {
      home = Team(
        division: 'home',
        quarters: {
          '1': 0,
          '2': 0,
          '3': 0,
          '4': 0,
        },
        players: {},
      );
    }

    Map getHome = jsonDecode(GSharedPreferences.getString('home')!);
    home = Team.fromMap(getHome);
  }

  void initAway() {
    if (GSharedPreferences.getString('away') == null) {
      away = Team(
        division: 'away',
        quarters: {
          '1': 0,
          '2': 0,
          '3': 0,
          '4': 0,
        },
        players: {},
      );
      return;
    }

    Map getAway = jsonDecode(GSharedPreferences.getString('away')!);
    away = Team.fromMap(getAway);
  }

  void setAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

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

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
