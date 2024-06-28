import 'dart:math';
import 'dart:ui';

class ScreenParams{
  static late Size screenSize;
  static late Size previewSize;

  static double previewRatio = max(previewSize.height, previewSize.height) /
  min(previewSize.height, previewSize.height);

  static Size screenPreviewSize =
      Size(screenSize.width, screenSize.width * previewRatio);
}