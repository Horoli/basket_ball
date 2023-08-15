part of 'common.dart';

const String RESET_BUTTON = 'reset';
const String MAP_OF_POSITIONS = 'mapOfPositions';

const String DRAWING_DISABLE = '그리기 비활성화\n(이동가능)';
const String DRAWING_ABLE = '그리기 활성화\n(이동불가)';
const String DRAWING_CLEAR = '그림 지우기';
const String DRAWING_OPTION = '그리기 옵션';

const String COLOR_SELECT = '색상 선택';

const double defaultDx = 70;
const double defaultDy = 150;

const Color COLOR_APPBAR = ui.Color.fromARGB(255, 41, 84, 122);
const Color COLOR_HOME = ui.Color.fromARGB(255, 108, 141, 170);
const Color COLOR_AWAY = ui.Color.fromARGB(255, 196, 136, 131);
const Color COLOR_WHITE = Colors.white;
const Color COLOR_BLACK = Colors.black;
const Color COLOR_YELLOW = Colors.yellow;
const Color COLOR_ORANGE = Colors.orange;
const Color COLOR_CYAN = Colors.cyan;

Widget buildBasicButton({
  required child,
  required VoidCallback? onPressed,
  Color backgroundColor = COLOR_HOME,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      textStyle: const TextStyle(color: Colors.black),
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
    ),
    onPressed: onPressed,
    child: child,
  );
}

Widget buildTextButton({
  required child,
  required VoidCallback? onPressed,
}) {
  return TextButton(
    style: TextButton.styleFrom(
      // side: BorderSide(color: Colors.grey),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
    ),
    child: child,
    onPressed: onPressed,
  );
}

Widget buildBorderContainer({
  Widget? child,
  double? width,
  double? height,
}) {
  return Padding(
    padding: const EdgeInsets.all(3),
    child: Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: child,
      ),
    ),
  );
}
