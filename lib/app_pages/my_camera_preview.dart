import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:johannes_test/app_pages/showing_pictures.dart';
import 'package:johannes_test/app_state_manager/my_app_state.dart';
import 'package:johannes_test/app_widgets/camera_button.dart';
import 'package:johannes_test/main.dart';
import 'package:johannes_test/my_utils/base.dart';
import 'package:johannes_test/my_utils/const.dart';
import 'package:provider/provider.dart';

class MyCameraPreview extends StatefulWidget {
  static const routeName = "/";

  @override
  _MyCameraPreviewState createState() => _MyCameraPreviewState();
}

class _MyCameraPreviewState extends State<MyCameraPreview> {
  late CameraController controller;
  bool permissionDenied = false;
  bool isLoading = true;
  int recaptureIndex = -1;
  bool flashState = false;
  late List<CameraDescription> _availableCameras;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final passedArgs = ModalRoute.of(context)!.settings.arguments;

      recaptureIndex =
          passedArgs == null ? -1 : (passedArgs as Map)["recaptureIndex"];

      setState(() {
        isLoading = false;
      });
    });

    /// Used to set the landscape for just this page.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    availableCameras().then((value) {
      _availableCameras = value;
    });
    cameraInitial(cameras[0]);
  }

  void cameraInitial(CameraDescription description) async {
    controller = CameraController(description, ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) async {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            permissionDenied = true;
            break;
          default:
            showSnackBar(
              context: context,
              msg: "Please accept the permission!",
              txtColor: Colors.white,
              bgColor: Colors.red,
            );
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();

    /// Used to back primary mode of orientation.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (!controller.value.isInitialized || isLoading)
          ? const Center(child: CircularProgressIndicator())
          : permissionDenied
          ? const Center(
        child: Text(
          "Please let the app to use camera",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
      )
          : SizedBox(
        width: getDeviceSize(context).width,
        child: CameraPreview(
          controller,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SizedBox(
                    height: getDeviceSize(context).height,
                    width: getDeviceSize(context).width * 0.714,
                    child: Image.asset(
                      "assets/images/overlay.png",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const Positioned(
                    bottom: 30,
                    child: Text(
                      "Front Retracted",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              Container(
                width: getDeviceSize(context).width * 0.286,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/black_lather.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                        height: getDeviceSize(context).height * 0.12,
                    ),
                    CameraButton(
                      btnTxt: "FLASH",
                      imagePath: "assets/images/thunder.png",
                      txtColor: MyColors.flashColor,
                      imgHeight: getDeviceSize(context).height * 0.06,
                      imgWidth: getDeviceSize(context).height * 0.06,
                      mFunc: () {
                        flashState = !flashState;
                        if (flashState) {
                          controller.setFlashMode(FlashMode.torch);
                        } else {
                          controller.setFlashMode(FlashMode.off);
                        }
                      },
                    ),
                    SizedBox(
                      height: getDeviceSize(context).height * 0.05,
                    ),
                    CameraButton(
                      btnTxt: "MIRROR",
                      imagePath: "assets/images/sync.png",
                      txtColor: MyColors.mirrorColor,
                      imgHeight: getDeviceSize(context).height * 0.06,
                      imgWidth: getDeviceSize(context).height * 0.06,
                      mFunc: () {
                        // get current lens direction (front / rear)
                        final lensDirection = controller.description
                            .lensDirection;
                        CameraDescription newDescription;
                        if (lensDirection ==
                            CameraLensDirection.front) {
                          newDescription = _availableCameras
                              .firstWhere((description) =>
                          description.lensDirection ==
                              CameraLensDirection.back);
                        }
                        else {
                          newDescription = _availableCameras
                              .firstWhere((description) =>
                          description.lensDirection ==
                              CameraLensDirection.front);
                        }

                        if (newDescription != null) {
                          cameraInitial(newDescription);
                        }
                        else {
                          showSnackBar(
                            context: context,
                            msg: "Asked camera not available!",
                            txtColor: Colors.white,
                            bgColor: Colors.red,
                          );
                        }
                      },
                    ),
                    SizedBox(
                        height: getDeviceSize(context).height * 0.08,
                    ),
                    InkWell(
                      child: Container(
                        width: getDeviceSize(context).height * 0.2,
                        height: getDeviceSize(context).height * 0.2,
                        margin: EdgeInsets.only(
                          right: getDeviceSize(context).width * 0.04,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              getDeviceSize(context).height * 0.1,
                            ),
                          ),
                          border: Border.all(
                            color: MyColors.captureBtnBorder,
                            width: 3,
                          ),
                          gradient: const RadialGradient(
                            center: Alignment.center,
                            colors: [
                              MyColors.btnColorEnd,
                              MyColors.btnColorStart,
                            ],
                          ),
                        ),
                      ),
                      onTap: () async {
                        XFile imageCaptured =
                        await controller.takePicture();
                        if (recaptureIndex == -1) {
                          bool added = Provider.of<MyAppState>(
                              context,
                              listen: false)
                              .addImage(imageCaptured);

                          if (!added) {
                            Navigator.pushReplacementNamed(
                                context, ShowingPictures.routeName,
                            );
                          }
                        } else {
                          Provider.of<MyAppState>(
                            context,
                            listen: false,
                          ).recaptureImage(
                            imageCaptured,
                            recaptureIndex,
                          );

                          Navigator.pushReplacementNamed(
                              context, ShowingPictures.routeName);
                        }
                      },
                    ),
                    SizedBox(
                        height: getDeviceSize(context).height * 0.04,
                    ),
                    const Text(
                      "CAPTURE",
                      style: TextStyle(color: MyColors.mirrorColor),
                    ),
                    SizedBox(
                        height: getDeviceSize(context).height * 0.1,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: getDeviceSize(context).height * 0.12,
                      ),
                      child: MyElevatedButton(
                        btnWidth: getDeviceSize(context).width * 0.08,
                        btnHeight:
                        getDeviceSize(context).height * 0.08,
                        borderRadius: 5,
                        btnChild: const Text(
                          "<BACK",
                          style: TextStyle(
                              color: Colors.red, fontSize: 13),
                        ),
                        btnStyle: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shadowColor: Colors.transparent,
                          primary: Colors.transparent,
                        ),
                        clickListener: () {

                          Provider.of<MyAppState>(
                            context,
                            listen: false,
                          ).removeLastImage();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}