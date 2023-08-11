part of '/common.dart';

class ViewOperationBoard extends StatefulWidget {
  const ViewOperationBoard({super.key});
  @override
  ViewOperationBoardState createState() => ViewOperationBoardState();
}

class ViewOperationBoardState extends State<ViewOperationBoard> {
  final String resetButton = 'reset';
  final String mapName = 'mapOfPositions';
  double get fullWidth => MediaQuery.of(context).size.width;
  double get fullHeight => MediaQuery.of(context).size.height;

  double unitWidth = 50.0, unitHeight = 50.0;

  TStream<Map<String, List<double>>> $mapOfPositions =
      TStream<Map<String, List<double>>>()..sink$({});

  @override
  Widget build(BuildContext context) {
    return TStreamBuilder(
        stream: $mapOfPositions.browse$,
        builder: (context, Map<String, List<double>> mapOfPositions) {
          return Stack(
            children: [
              Positioned(top: 0, right: 0, child: buildResetButton()),
              for (String key in mapOfPositions.keys.toList())
                buildPositioned(key, mapOfPositions[key]!),
            ],
          );
        });
  }

  Widget buildResetButton() {
    return buildTextButton(
      child: const Icon(
        Icons.refresh,
        color: homeColor,
      ),
      onPressed: () {
        GSharedPreferences.remove(mapName);
        $mapOfPositions.sink$(defaultPositions);
      },
    );
  }

  Widget buildPositioned(String key, List<double> position) {
    bool isHomeTeam = key.contains('H-');
    bool isBall = key == 'ball';

    return Positioned(
      left: position.first,
      top: position.last - unitHeight,
      child: Draggable(
        feedback: Material(
          type: MaterialType.transparency,
          child: isBall
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.3),
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                  width: unitWidth,
                  height: unitHeight,
                )
              : Container(
                  decoration: BoxDecoration(
                      color: isHomeTeam
                          ? homeColor.withOpacity(0.3)
                          : awayColor.withOpacity(0.3),
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
          // tmpMap[key] = beforeOffset;

          String jsonPosition = jsonEncode(tmpMap);
          $mapOfPositions.sink$(tmpMap);

          GSharedPreferences.setString(mapName, jsonPosition);
        },
        child: isBall
            ? Container(
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                width: unitWidth,
                height: unitHeight,
              )
            : Container(
                decoration: BoxDecoration(
                    color: isHomeTeam ? homeColor : awayColor,
                    borderRadius: const BorderRadius.all(Radius.circular(30))),
                width: unitWidth,
                height: unitHeight,
                // color: Colors.blue,
                child: Center(
                    child: Text(
                  key,
                  style: const TextStyle(color: Colors.white),
                )),
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
    if (GSharedPreferences.get(mapName) == null) {
      $mapOfPositions.sink$(defaultPositions);
      return;
    }

    String getData = GSharedPreferences.get(mapName)!.toString();

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
    'H-1': [0.0, 100],
    'H-2': [0.0, 200],
    'H-3': [0.0, 300],
    'H-4': [0.0, 400],
    'H-5': [0.0, 500],
    'A-1': [75.0, 100],
    'A-2': [75.0, 200],
    'A-3': [75.0, 300],
    'A-4': [75.0, 400],
    'A-5': [75.0, 500],
    'ball': [0.0, 600],
  };
}
