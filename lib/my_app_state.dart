import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

/// MyAppState is used to manage the state of captured images
class MyAppState extends ChangeNotifier {
  List<XFile> _imageArrays = [];

  List<XFile> get imageArrays {
    return _imageArrays;
  }

  /// After capturing 9 images then the user will go to showing image page
  bool addImage(XFile newImage) {
    if (_imageArrays.length >= 2) {
      if (_imageArrays.length < 3) _imageArrays.add(newImage);
      notifyListeners();
      print("Mahdi: addImage: inside: ${_imageArrays.length}");
      return false;
    }
    _imageArrays.add(newImage);
    print("Mahdi: addImage: outside: ${_imageArrays.length}");
    return true;
  }

  /// User can recapture an image by tap on the image
  void recaptureImage(XFile newImage, int replaceIndex) {
    _imageArrays[replaceIndex] = newImage;
    notifyListeners();
  }
}
// testmailjohan366@gmail.com
// 123!@#asd