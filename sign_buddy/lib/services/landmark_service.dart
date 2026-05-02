
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'dart:math';
class LandmarkService {
  static const _channel = MethodChannel('sign_buddy/mediapipe');

  static List<double>? _normalize(List<double> landmarks){
    if (landmarks.length != 63) return null;

    final double wx = landmarks[0];
    final double wy = landmarks[1];
    final double wz = landmarks[2];

    final centered = List<double>.generate(63, (i){
      if(i%3==0) return landmarks[i] - wx;
      if(i%3==1) return landmarks[i] - wy;
      return landmarks[i] - wz;
    });

    final double maxVal = centered.map((v) => v.abs()).reduce(max);
    if (maxVal == 0) return centered;

    return centered.map((v) => v/maxVal).toList();
  }

  static Future<List<double>?> extractLandmarks(CameraImage image) async {
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
      final raw = List<double>.from(result);

      return _normalize(raw);

    }
    catch (e) {
      print("LANDMARK ERROR; $e");

      return null;
    }
  }

  static Uint8List _toNV21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final int ySize = width * height;
    final int uvSize = width * height ~/ 2;
    final nv21 = Uint8List(ySize + uvSize);

    // Copy Y plane row by row (handles row stride padding)
    for (int row = 0; row < height; row++) {
      final srcOffset = row * yPlane.bytesPerRow;
      final dstOffset = row * width;
      nv21.setRange(dstOffset, dstOffset + width, yPlane.bytes, srcOffset);
    }

    // Interleave V then U (NV21 = Y + VU interleaved)
    final int uvHeight = height ~/ 2;
    final int uvWidth = width ~/ 2;
    for (int row = 0; row < uvHeight; row++) {
      for (int col = 0; col < uvWidth; col++) {
        final srcIndex = row * uPlane.bytesPerRow + col * uPlane.bytesPerPixel!;
        final dstIndex = ySize + (row * width) + (col * 2);
        nv21[dstIndex] = vPlane.bytes[srcIndex]; // V first
        nv21[dstIndex + 1] = uPlane.bytes[srcIndex]; // then U
      }
    }

    return nv21;
  }
}