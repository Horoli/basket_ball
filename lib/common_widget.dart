part of 'common.dart';

const Color homeColor = ui.Color.fromARGB(255, 52, 92, 126);
const Color awayColor = ui.Color.fromARGB(255, 149, 63, 57);

Widget buildBasicButton({
  required child,
  required VoidCallback? onPressed,
  Color backgroundColor = homeColor,
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
