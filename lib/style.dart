import 'package:saferide/app_import.dart';

Widget simpleText(String text, double size, FontWeight weight, Color color, TextAlign align) {
  return Text(
    text,
    style: TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
    ),
    textAlign: align,
  );
}