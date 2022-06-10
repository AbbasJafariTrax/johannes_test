import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:johannes_test/app_pages/my_camera_preview.dart';
import 'package:johannes_test/my_app_state.dart';
import 'package:johannes_test/my_utils/base.dart';
import 'package:johannes_test/my_utils/const.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ShowingPictures extends StatefulWidget {
  static const routeName = "showing_pictures";

  @override
  State<ShowingPictures> createState() => _ShowingPicturesState();
}

class _ShowingPicturesState extends State<ShowingPictures> {
  List<int> myList = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  final TextEditingController _controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /// Used to set the landscape for just this page.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getDeviceSize(context).width * 0.05,
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                vertical: getDeviceSize(context).height * 0.05,
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: Consumer<MyAppState>(
                builder: (BuildContext context, value, Widget? child) {
                  return GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      crossAxisCount: 3,
                    ),
                    itemCount: value.imageArrays.length,
                    itemBuilder: (BuildContext ctx, int index) {
                      return FutureBuilder(
                        future: value.imageArrays[index].readAsBytes(),
                        builder: (ctx, AsyncSnapshot<Uint8List> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          return InkWell(
                            child: Image.memory(
                              snapshot.data ?? Uint8List(1),
                              fit: BoxFit.cover,
                              height: getDeviceSize(context).width * 0.3,
                              width: getDeviceSize(context).width * 0.3,
                            ),
                            onTap: () async {
                              var isGranted = await Permission.camera.isGranted;
                              // BuildContext context, String filename, Map body
                              if (!isGranted) {
                                await Permission.storage
                                    .request()
                                    .then((PermissionStatus status) async {
                                  if (status.isGranted) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      MyCameraPreview.routeName,
                                      arguments: {"recaptureIndex": index},
                                    );
                                  } else {
                                    openAppSettings();
                                  }
                                });
                              } else {
                                Navigator.pushReplacementNamed(
                                  context,
                                  MyCameraPreview.routeName,
                                  arguments: {"recaptureIndex": index},
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Form(
              key: _formKey,
              child: MyTextField(controller: _controller),
            ),
            SizedBox(height: getDeviceSize(context).height * 0.02),
            MyElevatedButton(
              btnWidth: getDeviceSize(context).width,
              btnHeight: getDeviceSize(context).height * 0.06,
              borderColor: Colors.white,
              borderRadius: 20,
              clickListener: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );

                  /// Send the images to the an email

                }
              },
              btnChild: const Text(
                "Send Email",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              btnStyle: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shadowColor: Colors.transparent,
                primary: MyColors.sendMailBtnColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
