import 'package:flutter/material.dart';

Color kPrimaryColor = Color.fromARGB(255, 255, 115, 92);
Color kSecondaryColor = Color.fromARGB(255, 56, 90, 100);
Color kNetralColor = Colors.white;
Color kBlackColor = Colors.black;
final kTitle = TextStyle(
  fontFamily: 'Manrope',
  fontSize: SizeConfig.blockSizeH! * 7,
  color: kPrimaryColor,
);

final kBodyText1 = TextStyle(
  color: kSecondaryColor,
  fontSize: SizeConfig.blockSizeH! * 4.5,
  fontWeight: FontWeight.bold,
);

class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeH;
  static double? blockSizeV;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeH = screenWidth! / 100;
    blockSizeV = screenHeight! / 100;
  }
}

class AppColors {
  static Color primary = Color.fromARGB(255, 255, 115, 92);
  static Color primaryFocus = Color.fromARGB(255, 255, 166, 152);
  static Color primaryContent = const Color.fromRGBO(255, 255, 255, 1);

  static Color secondary = Color.fromARGB(255, 56, 90, 100);
  static Color secondaryFocus = Color.fromARGB(255, 46, 127, 151);
  static Color secondaryContent = const Color.fromRGBO(255, 255, 255, 1);

  static Color accent = const Color.fromRGBO(248, 134, 13, 1);
  static Color accentFocus = const Color.fromRGBO(203, 108, 6, 1);
  static Color accentContent = const Color.fromRGBO(255, 255, 255, 1);

  static Color neutral = const Color.fromRGBO(30, 39, 52, 1);
  static Color neutralFocus = const Color.fromRGBO(17, 24, 29, 1);
  static Color neutralContent = const Color.fromRGBO(255, 255, 255, 1);

  static Color base100 = const Color.fromRGBO(255, 255, 255, 1);
  static Color base200 = const Color.fromRGBO(249, 250, 251, 1);
  static Color base300 = const Color.fromRGBO(206, 211, 217, 1);
  static Color baseContent = const Color.fromRGBO(30, 39, 52, 1);

  static Color info = const Color.fromRGBO(28, 146, 242, 1);
  static Color success = const Color.fromRGBO(0, 148, 133, 1);
  static Color warning = const Color.fromRGBO(255, 153, 0, 1);
  static Color error = const Color.fromRGBO(255, 87, 36, 1);
}
