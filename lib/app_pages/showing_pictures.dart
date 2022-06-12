import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:image/image.dart' as packageImage;
import 'package:johannes_test/app_pages/my_camera_preview.dart';
import 'package:johannes_test/my_utils/base.dart';
import 'package:johannes_test/my_utils/const.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../app_state_manager/my_app_state.dart';

class ShowingPictures extends StatefulWidget {
  static const routeName = "showing_pictures";

  @override
  State<ShowingPictures> createState() => _ShowingPicturesState();
}

class _ShowingPicturesState extends State<ShowingPictures> {
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
      body: SingleChildScrollView(
        child: Padding(
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
                      physics: const NeverScrollableScrollPhysics(),
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
                clickListener: () async {
                  if (_formKey.currentState!.validate()) {
                    // Get images from state management
                    List<XFile> imgList =
                        Provider.of<MyAppState>(context, listen: false)
                            .imageArrays;

                    // Get the first image to create mergedImage width and height
                    final image1 = packageImage
                        .decodeImage(File(imgList[0].path).readAsBytesSync());

                    var mergedImage;

                    if (image1 != null) {
                      // Create merged image
                      mergedImage = packageImage.Image(
                        image1.width + image1.width + image1.width,
                        image1.height + image1.height + image1.height,
                      );
                      packageImage.copyInto(mergedImage, image1, blend: false);
                    }

                    for (int mIndex = 0; mIndex < imgList.length; mIndex++) {
                      if (mIndex == 0) continue;

                      // Get current image
                      final tempImg = packageImage.decodeImage(
                          File(imgList[mIndex].path).readAsBytesSync());

                      // Merge image inside a square 3 x 3
                      if (tempImg != null) {
                        if (mIndex == 1 || mIndex == 4 || mIndex == 7) {
                          packageImage.copyInto(
                            mergedImage,
                            tempImg,
                            dstX: tempImg.width.toInt(),
                            dstY: mIndex == 1
                                ? 0
                                : mIndex == 4
                                    ? tempImg.height
                                    : tempImg.height + tempImg.height,
                            blend: false,
                          );
                        } else if (mIndex == 2 || mIndex == 5 || mIndex == 8) {
                          packageImage.copyInto(
                            mergedImage,
                            tempImg,
                            dstX: tempImg.width.toInt() + tempImg.width.toInt(),
                            dstY: mIndex == 2
                                ? 0
                                : mIndex == 5
                                    ? tempImg.height
                                    : tempImg.height + tempImg.height,
                            blend: false,
                          );
                        } else {
                          packageImage.copyInto(
                            mergedImage,
                            tempImg,
                            dstY: mIndex == 3
                                ? tempImg.height
                                : tempImg.height + tempImg.height,
                            blend: false,
                          );
                        }
                      }
                    }

                    // Create single image
                    final documentDirectory =
                        await getTemporaryDirectory();
                    final file =
                        File(join(documentDirectory.path, "merged_image.jpg"));
                    file.writeAsBytesSync(packageImage.encodeJpg(mergedImage));

                    // Create email body
                    final Email email = Email(
                      body: 'Email body',
                      subject: 'Email subject',
                      recipients: [_controller.text],
                      attachmentPaths: [file.path],
                      isHTML: false,
                    );

                    // Send the email
                    await FlutterEmailSender.send(email).whenComplete(() {
                      showSnackBar(
                        context: context,
                        msg: "Sending...",
                        txtColor: Colors.white,
                        bgColor: Colors.blue,
                      );
                    }).catchError((e) {
                      showSnackBar(
                        context: context,
                        msg: 'Something went wrong!',
                        txtColor: Colors.white,
                        bgColor: Colors.red,
                      );
                    });
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
      ),
    );
  }
}
