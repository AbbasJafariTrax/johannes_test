import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// MyAppState is used to manage the state of captured images
class MyAppState extends ChangeNotifier {
  final List<XFile> _imageArrays = [];

  List<XFile> get imageArrays {
    return _imageArrays;
  }

  /// After capturing 9 images then the user will go to showing image page
  Future<bool> addImage(XFile newImage) async {
    if (_imageArrays.length >= 8) {
      if (_imageArrays.length < 9) {
        _imageArrays.add(newImage);
      }
      notifyListeners();
      return false;
    }
    _imageArrays.add(newImage);
    return true;
  }

  /// User can recapture an image by tap on the image
  void recaptureImage(XFile newImage, int replaceIndex) async {
    _imageArrays[replaceIndex] = newImage;
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

}