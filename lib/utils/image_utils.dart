import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as image_lib;

Future<image_lib.Image?> convertCameraImageToImage(
    CameraImage cameraImage) async {
  image_lib.Image image;

  if (cameraImage.format.group == ImageFormatGroup.yuv420) {}
  return image;
}

image_lib.Image convertYUV420ToImage(CameraImage cameraImage) {
  final width = cameraImage.width;
  final height = cameraImage.height;
  final uvRowStride = cameraImage.planes[1].bytesPerRow;
  final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

  final yPlane = cameraImage.planes[0].bytes;
  final uPlane = cameraImage.planes[1].bytes;
  final vPlane = cameraImage.planes[2].bytes;

  final image = image_lib.Image(width: width, height: height);

  var uvIndex = 0;

  for (var y = 0; y < height; y++) {
    var pY = y * width;
    var pUV = uvIndex;

    for (var x = 0; x < width; x++) {
      final yValue = yPlane[pY];
      final uValue = uPlane[pUV];
      final vValue = vPlane[pUV];

      final r = yValue + 1.402 * (vValue - 128);
      final g = yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128);
      final b = yValue + 1.772 * (uValue - 128);

      image.setPixelRgba(x, y, r.toInt(), g.toInt(), b.toInt(), 255);

      pY++;
      if (x % 2 == 1 && uvPixelStride == 2) {
        pUV += uvPixelStride;
      } else if (x % 2 == 1 && uvPixelStride == 1) {
        pUV++;
      }
    }
    if (y % 2 == 1) {
      uvIndex += uvRowStride;
    }
  }
  return image;
}

image_lib.Image convertBGRA8888ToImage(CameraImage cameraImage) {
  // Extract the bytes from the CameraImage

  final bytes = cameraImage.planes[0].bytes;
  // create a new image instance
  final image = image_lib.Image.fromBytes(
    width: cameraImage.width,
    height: cameraImage.height,
    bytes: bytes.buffer,
    order: image_lib.ChannelOrder.rgba,
  );
  return image;
}

image_lib.Image convertJPEGToImage(CameraImage cameraImage) {
  // Extract the Bytes from the camera Image
  final bytes = cameraImage.planes[0].bytes;

  // create a new image instance from the JPEG bytes

  final image = image_lib.decodeImage(bytes);

  return image!;
}

image_lib.Image convertN21ToImage(CameraImage cameraImage){
  // Extract the bytes from the CameraImage

  final yuvBytes = cameraImage.planes[0].bytes;
  final vuvBytes = cameraImage.planes[1].bytes;

  // create a new Image Distance
  final image = image_lib.Image(
    width: cameraImage.width,
    height: cameraImage.height,
  );

  // convert NV21 to RGB
  convertNV21ToRGB(
    yuvBytes,
    vuvBytes,
    cameraImage.width,
    cameraImage.height,
    image,
  );
  return image;
}

void convertNV21ToRGB(Uint8List yuvBytes, Uint8List vuBytes, int width, int height, image_lib.Image image){
  for (var y = 0; y < height; y++){
    for(var x = 0; x < width; x++){
      final yIndex = y * width + x;
      final uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);

      final yValue = yuvBytes[yIndex];
      final uValue = vuBytes[uvIndex * 2];
      final vValue = vuBytes[uvIndex * 2 + 1];

      // Convert YUV to RGB
      final r = yValue + 1.402 * (vValue - 128);
      final g = yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128);
      final b = yValue + 1.772 * (uValue - 128);

      // Set the RGB pixel values in the Image instance
      image.setPixelRgba(x, y, r.toInt(), g.toInt(), b.toInt(), 255);
    }
  }
}

