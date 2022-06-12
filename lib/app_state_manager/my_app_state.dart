import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

/// MyAppState is used to manage the state of captured images
class MyAppState extends ChangeNotifier {
  final List<XFile> _imageArrays = [];

  List<XFile> get imageArrays {
    return _imageArrays;
  }

  /// After capturing 9 images then the user will go to showing image page
  Future<bool> addImage(XFile newImage) async {
    if (_imageArrays.length >= 1) {
      if (_imageArrays.length < 2) {
        String mPath = await _resizePhoto(newImage.path);
        _imageArrays.add(XFile(mPath));
      }
      notifyListeners();
      return false;
    }
    String mPath = await _resizePhoto(newImage.path);
    _imageArrays.add(XFile(mPath));
    return true;
  }

  /// User can recapture an image by tap on the image
  void recaptureImage(XFile newImage, int replaceIndex) async {
    String mPath = await _resizePhoto(newImage.path);
    _imageArrays[replaceIndex] = XFile(mPath);
    notifyListeners();
  }

  bool removeLastImage() {
    if (_imageArrays.isNotEmpty) {
      _imageArrays.removeLast();
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  Future<String> _resizePhoto(String filePath) async {
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(filePath);

    int? width = properties.width;
    var offset = (properties.height! - properties.width!) / 2;

    File croppedFile = await FlutterNativeImage.cropImage(
      filePath,
      0,
      offset.round(),
      width!,
      width,
    );

    return croppedFile.path;
  }
}