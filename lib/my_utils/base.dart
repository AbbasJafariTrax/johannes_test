import 'package:flutter/material.dart';

import 'const.dart';

void showSnackBar({
  required BuildContext context,
  required String msg,
  required Color txtColor,
  required Color bgColor,
}) {
  final snackBar = SnackBar(
    content: Text(
      msg,
      style: const TextStyle(color: Colors.black),
    ),
    backgroundColor: Colors.blue,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class MyElevatedButton extends StatelessWidget {
  final VoidCallback clickListener;
  final Widget btnChild;
  final ButtonStyle btnStyle;
  final double btnWidth;
  final double btnHeight;
  final Color borderColor;
  final double borderRadius;

  const MyElevatedButton({
    Key? key,
    required this.clickListener,
    required this.btnChild,
    required this.btnStyle,
    required this.btnWidth,
    required this.btnHeight,
    required this.borderRadius,
    this.borderColor = MyColors.btnBorderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: btnWidth,
      height: btnHeight,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        gradient: const LinearGradient(
          colors: [
            MyColors.btnColorStart,
            MyColors.btnColorEnd,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // stops: [0.0, 1.0],
        ),
      ),
      child: ElevatedButton(
        onPressed: clickListener,
        child: btnChild,
        style: btnStyle,
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController controller;

  const MyTextField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: getDeviceSize(context).width * 0.04,
        ),
        hintText: "Email",
        hintStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        fillColor: MyColors.txtFieldColor,
        filled: true,
        border: InputBorder.none,
      ),
      validator: (inputVal) {
        bool emailValid = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(inputVal ?? "");

        if (emailValid) {
          return null;
        }
        return "Invalid email";
      },
    );
  }
}
