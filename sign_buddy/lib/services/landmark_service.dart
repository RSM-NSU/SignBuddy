
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class LandmarkService {
  static const _channel = MethodChannel('sign_buddy/mediapipe');

  static Future<List<double>?> extractLandmarks(CameraImage image) async{
    print("Planes: ${image.planes.length}");
    print("Width: ${image.width}");
    print("Height: ${image.height}");
    try {
      final bytes = _toNV21(image);
      final result = await _channel.invokeMethod('detectLandmarks',
          {
            'bytes': bytes,
            'width': image.width,
            'height': image.height,

          });

      if (result == null) return null;
      return List<double>.from(result);
    }
    catch(e){
      print("LANDMARK ERROR; $e");

      return null;
    }

    }
  static Uint8List _toNV21(CameraImage image){
  final yPlane = image.planes[0].bytes;
  final uPlane = image.planes[1].bytes;
  final vPlane = image.planes[2].bytes;
  final nv21 = Uint8List(yPlane.length + uPlane.length + vPlane.length);



  nv21.setRange(0, yPlane.length, yPlane);
  for(int i = 0; i<uPlane.length; i++){
    nv21[yPlane.length + i * 2] = vPlane[i];
    nv21[yPlane.length+i*2+1] = uPlane[i];

  }


  return nv21;
}

}