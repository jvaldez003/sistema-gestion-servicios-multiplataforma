import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('assets/logo.png');
  if (!file.existsSync()) {
    print('logo.png no existe');
    return;
  }
  final image = img.decodeImage(file.readAsBytesSync());
  if (image == null) return;

  // Adaptive icon requires 108dp x 108dp, inner 72dp is safe zone.
  // We make a 1024x1024 image, and the safe zone is about 680x680.
  // Let's scale the logo so it fits in 680x680.
  final canvasSize = 1024;
  final safeSize = 600;

  // Calculate scale to fit in safeSize
  double scale = 1.0;
  if (image.width > image.height) {
    scale = safeSize / image.width;
  } else {
    scale = safeSize / image.height;
  }

  final newW = (image.width * scale).toInt();
  final newH = (image.height * scale).toInt();

  final resized = img.copyResize(image, width: newW, height: newH);

  // Create a transparent 1024x1024 canvas
  final canvas = img.Image(width: canvasSize, height: canvasSize, numChannels: 4);
  img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));

  // Draw the resized logo into the center
  final dstX = (canvasSize - newW) ~/ 2;
  final dstY = (canvasSize - newH) ~/ 2;

  img.compositeImage(canvas, resized, dstX: dstX, dstY: dstY);

  File('assets/logo_foreground.png').writeAsBytesSync(img.encodePng(canvas));
  print('Generado logo_foreground.png');
}
