import 'package:flutter/material.dart';

/// getDeviceSize return the device size
Size getDeviceSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

/// Application colors
class MyColors {
  static const Color flashColor = Color(0xff65d244);
  static const Color mirrorColor = Color(0xff939695);
  static const Color btnColorStart = Color(0xff1e1e1e);
  static const Color btnColorEnd = Color(0xff303030);
  static const Color iconColor = Color(0xffc1c2c6);
  static const Color btnBorderColor = Color(0xff414141);
  static const Color captureBtnBorder = Color(0xfff3f2f0);
  static const Color sendMailBtnColor = Color(0xff4c92ff);
  static const Color txtFieldColor = Color(0xffeceff2);
}
