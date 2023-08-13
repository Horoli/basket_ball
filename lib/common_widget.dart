part of 'common.dart';

const double defaultDx = 70;
const double defaultDy = 150;

const Color colorAppBar = ui.Color.fromARGB(255, 41, 84, 122);
const Color colorHome = ui.Color.fromARGB(255, 108, 141, 170);
const Color colorAway = ui.Color.fromARGB(255, 196, 136, 131);
const Color colorWhite = Colors.white;
const Color colorBlack = Colors.black;
const Color colorYellow = Colors.yellow;
const Color colorOrange = Colors.orange;
const Color colorCyan = Colors.cyan;

Widget buildBasicButton({
  required child,
  required VoidCallback? onPressed,
  Color backgroundColor = colorHome,
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
