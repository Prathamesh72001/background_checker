import 'package:flutter/widgets.dart';

class Sizes {
  static late double scaleFactor;
  static late double screenWidth;
  static late double screenHeight;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;

    scaleFactor = (size.width / 1920).clamp(0.6, 1.0);
  }
}
