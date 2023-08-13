part of '/common.dart';

class ViewOperationBoard extends StatefulWidget {
  const ViewOperationBoard({super.key});
  @override
  ViewOperationBoardState createState() => ViewOperationBoardState();
}

class ViewOperationBoardState extends State<ViewOperationBoard> {
  final double unitWidth = 40.0, unitHeight = 40.0;
  final TStream<Map<String, List<double>>> $mapOfPositions =
      TStream<Map<String, List<double>>>()..sink$({});
  final TStream<bool> $usePad = TStream<bool>()..sink$(false);
  final TStream<ByteData> $padData = TStream<ByteData>();
  final TStream<Color> $strokeColor = TStream<Color>()..sink$(Colors.black);

  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();

  double get fullWidth => MediaQuery.of(context).size.width;
  double get fullHeight => MediaQuery.of(context).size.height;

  @override
  Widget build(BuildContext context) {
    return TStreamBuilder(
        stream: $usePad.browse$,
        builder: (context, bool usePad) {
          return TStreamBuilder(
              stream: $mapOfPositions.browse$,
              builder: (context, Map<String, List<double>> mapOfPositions) {
                return Column(
                  children: [
                    Row(
                      children: [
                        buildResetButton().expand(),
                        buildUsePadButton(usePad).expand(),
                      ],
                    ).sizedBox(height: kToolbarHeight),
                    const Divider(),
                    Stack(
                      children: [
                        // Container(
                        //   height: 600,
                        //   decoration: BoxDecoration(
                        //     image: DecorationImage(
                        //       image: const AssetImage(operationBoardImage),
                        //       colorFilter: ColorFilter.mode(
                        //         Colors.white.withOpacity(1),
                        //         BlendMode.modulate,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        Center(
                          child: Image.asset(
                            operationBoardImage,
                            fit: BoxFit.fill,
                          ),
                        ),
                        for (String key in mapOfPositions.keys.toList())
                          buildPositioned(key, mapOfPositions[key]!),
                        if (usePad)
                          Center(
                            child: SizedBox(
                              width: fullWidth,
                              height: fullHeight,
                              child: SfSignaturePad(
                                key: signatureGlobalKey,
                                strokeColor: $strokeColor.lastValue,
                                minimumStrokeWidth: 2,
                                maximumStrokeWidth: 2,
                              ),
                            ),
                          ),
                      ],
                    ).expand(),
                    const Divider(),
                    usePad
                        ? buildExchangePadColor()
                            .sizedBox(height: kToolbarHeight)
                        : Container().sizedBox(height: kToolbarHeight),
                    // const Padding(padding: EdgeInsets.all(10)),
                  ],
                );
              });
        });
  }

  Widget buildUsePadButton(bool usePad) {
    return buildTextButton(
        child: usePad
            ? const Text(DRAWING_ABLE,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ))
            : const Text(
                DRAWING_DISABLE,
                textAlign: TextAlign.center,
              ),
        onPressed: () async {
          usePad ? $usePad.sink$(false) : $usePad.sink$(true);

          // 현재 패드가 use인 경우, padData를 저장함
          // if (usePad) {
          // await signatureGlobalKey.currentState!.toImage();
          // final padData =
          //     await signatureGlobalKey.currentState!.toImage(pixelRatio: 3);
          // print('padData $padData');

          // final bytes =
          //     await padData.toByteData(format: ui.ImageByteFormat.png);
          //   $usePad.sink$(false);
          //   return;
          // }

          // $usePad.sink$(true);
        });
  }

  Widget buildExchangePadColor() {
    return Column(
      children: [
        SizedBox(
          width: fullWidth,
          child: const Text(
            DRAWING_OPTION,
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              const Text(COLOR_SELECT),
              const VerticalDivider(),
              buildSelectColorButton(COLOR_WHITE).expand(),
              buildSelectColorButton(COLOR_BLACK).expand(),
              buildSelectColorButton(COLOR_YELLOW).expand(),
              buildSelectColorButton(COLOR_ORANGE).expand(),
              buildSelectColorButton(COLOR_CYAN).expand(),
            ]).expand(),
            const VerticalDivider(),
            Row(children: [
              const Text(DRAWING_CLEAR),
              const VerticalDivider(),
              buildBasicButton(
                child: const Icon(Icons.remove_from_queue_rounded),
                onPressed: () {
                  signatureGlobalKey.currentState!.clear();
                },
              )
            ]).expand(),
          ],
        ),
      ],
    );
  }

  Widget buildSelectColorButton(Color color) {
    return buildBasicButton(
        child: Text(''),
        // child: Container(),
        backgroundColor: color,
        onPressed: () {
          $strokeColor.sink$(color);
          $usePad.sink$(true);
        });
  }

  Widget buildResetButton() {
    return buildTextButton(
      child: const Icon(
        Icons.refresh,
        color: COLOR_HOME,
      ),
      onPressed: () {
        GSharedPreferences.remove(MAP_OF_POSITIONS);
        $mapOfPositions.sink$(defaultPositions);
      },
    );
  }

  Widget buildPositioned(String key, List<double> position) {
    bool isHomeTeam = key.contains('H-');
    bool isBall = key == 'ball';

    return Positioned(
      left: position.first,
      top: position.last - kToolbarHeight - 70,
      child: Draggable(
        feedback: Material(
          type: MaterialType.transparency,
          child: isBall
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.3),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                  width: unitWidth * 0.8,
                  height: unitHeight * 0.8,
                )
              : Container(
                  decoration: BoxDecoration(
                      color: isHomeTeam
                          ? COLOR_HOME.withOpacity(0.3)
                          : COLOR_AWAY.withOpacity(0.3),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(30))),
                  width: unitWidth,
                  height: unitHeight,
                  child: Center(
                      child: Text(
                    key,
                    style: const TextStyle(color: Colors.white),
                  )),
                ),
        ),
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          print('$key offset $offset');
          List<double> beforeOffset = [offset.dx, offset.dy];

          Map<String, List<double>> tmpMap = Map.from($mapOfPositions.lastValue)
            ..[key] = beforeOffset;

          String jsonPosition = jsonEncode(tmpMap);
          $mapOfPositions.sink$(tmpMap);

          GSharedPreferences.setString(MAP_OF_POSITIONS, jsonPosition);
        },
        child: isBall
            ? Container(
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                width: unitWidth * 0.8,
                height: unitHeight * 0.8,
              )
            : Container(
                decoration: BoxDecoration(
                    color: isHomeTeam ? COLOR_HOME : COLOR_AWAY,
                    borderRadius: const BorderRadius.all(Radius.circular(30))),
                width: unitWidth,
                height: unitHeight,
                child: Center(
                  child: Text(key, style: const TextStyle(color: Colors.white)),
                ),
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    initData();
  }

  Future initData() async {
    if (GSharedPreferences.get(MAP_OF_POSITIONS) == null) {
      $mapOfPositions.sink$(defaultPositions);
      return;
    }

    String getData = GSharedPreferences.get(MAP_OF_POSITIONS)!.toString();

    Map jsonData = jsonDecode(getData);

    Map<String, List<double>> tmpMap = {};

    for (String key in jsonData.keys) {
      List getValue = jsonData[key];
      List<double> convertGetValue =
          getValue.map((e) => double.parse(e.toString())).toList();
      tmpMap[key] = convertGetValue;
    }

    $mapOfPositions.sink$(tmpMap);
  }

  final Map<String, List<double>> defaultPositions = {
    'H-1': [defaultDx * 0, defaultDy],
    'H-2': [defaultDx * 1, defaultDy],
    'H-3': [defaultDx * 2, defaultDy],
    'H-4': [defaultDx * 3, defaultDy],
    'H-5': [defaultDx * 4, defaultDy],
    'A-1': [defaultDx * 0, defaultDy + kToolbarHeight],
    'A-2': [defaultDx * 1, defaultDy + kToolbarHeight],
    'A-3': [defaultDx * 2, defaultDy + kToolbarHeight],
    'A-4': [defaultDx * 3, defaultDy + kToolbarHeight],
    'A-5': [defaultDx * 4, defaultDy + kToolbarHeight],
    'ball': [defaultDx * 0, defaultDy + kToolbarHeight * 2],
  };
}
