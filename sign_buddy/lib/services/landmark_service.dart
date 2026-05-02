
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class LandmarkService {
  static const _channel = MethodChannel('sign_buddy/mediapipe');

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
      return List<double>.from(result);
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