import 'package:flutter/material.dart';

import '../my_utils/base.dart';
import '../my_utils/const.dart';

class CameraButton extends StatelessWidget {
  final VoidCallback mFunc;
  final String btnTxt;
  final String imagePath;
  final Color txtColor;
  final double imgHeight;
  final double imgWidth;

  const CameraButton({
    Key? key,
    required this.mFunc,
    required this.btnTxt,
    required this.imagePath,
    required this.txtColor,
    required this.imgHeight,
    required this.imgWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: getDeviceSize(context).height * 0.12,
        left: getDeviceSize(context).height * 0.12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyElevatedButton(
            btnWidth: getDeviceSize(context).width * 0.12,
            btnHeight: getDeviceSize(context).height * 0.1,
            borderRadius: 5,
            btnStyle: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              shadowColor: MaterialStateProperty.all(Colors.transparent),
            ),
            btnChild: Text(
              btnTxt,
              style: TextStyle(color: txtColor, fontSize: 15),
            ),
            clickListener: mFunc,
          ),
          Image.asset(imagePath, height: imgHeight, width: imgWidth)
        ],
      ),
    );
  }
}
