import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:johannes_test/app_pages/my_camera_preview.dart';
import 'package:johannes_test/app_pages/showing_pictures.dart';
import 'package:johannes_test/my_app_state.dart';
import 'package:provider/provider.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MyAppState>(create: (_) => MyAppState())
      ],
      child: const CameraApp(),
    ),
  );
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({Key? key}) : super(key: key);

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: MyCameraPreview.routeName,
        routes: {
          MyCameraPreview.routeName: (context) => MyCameraPreview(),
          ShowingPictures.routeName: (context) => ShowingPictures(),
        },
      );
}
