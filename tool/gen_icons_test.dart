// Generates the launcher icon source PNGs. Run explicitly with:
//   flutter test tool/gen_icons_test.dart
// then: dart run flutter_launcher_icons
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const bg = Color(0xFF0F5C4D);
const gold = Color(0xFFC9A24B);
const goldLight = Color(0xFFE7CF95);

Future<ui.Image> render({required bool transparentBg, required double kaabaFrac}) async {
  const size = 1024.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  if (!transparentBg) {
    // background with a subtle vertical depth
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, size, size),
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(size / 2, 0),
          const Offset(size / 2, size),
          [const Color(0xFF13685A), const Color(0xFF0A4237)],
        ),
    );
  }

  final s = size * kaabaFrac; // kaaba width
  final cx = size / 2;
  final cy = size / 2;
  final body = RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset(cx, cy + s * 0.02), width: s, height: s),
    Radius.circular(s * 0.09),
  );

  // gold body with slight gradient
  canvas.drawRRect(
    body,
    Paint()
      ..shader = ui.Gradient.linear(
        Offset(cx, cy - s / 2),
        Offset(cx, cy + s / 2),
        [goldLight, gold],
      ),
  );

  // kiswa belt (band) in background green
  final bandPaint = Paint()..color = bg;
  final bandTop = body.top + s * 0.20;
  canvas.drawRect(Rect.fromLTWH(body.left, bandTop, s, s * 0.13), bandPaint);

  // door notch, offset to the right, rising from the bottom edge
  final doorW = s * 0.17;
  final doorH = s * 0.30;
  final doorLeft = body.left + s * 0.58;
  canvas.drawRRect(
    RRect.fromRectAndCorners(
      Rect.fromLTWH(doorLeft, body.bottom - doorH, doorW, doorH),
      topLeft: Radius.circular(doorW * 0.45),
      topRight: Radius.circular(doorW * 0.45),
    ),
    bandPaint,
  );

  final picture = recorder.endRecording();
  return picture.toImage(size.toInt(), size.toInt());
}

Future<void> save(ui.Image img, String path) async {
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(data!.buffer.asUint8List());
}

void main() {
  test('generate launcher icon PNGs', () async {
    final full = await render(transparentBg: false, kaabaFrac: 0.50);
    await save(full, 'assets/icon/app_icon.png');
    // adaptive foreground: content must fit the inner ~66% safe zone
    final fg = await render(transparentBg: true, kaabaFrac: 0.38);
    await save(fg, 'assets/icon/app_icon_fg.png');
    expect(File('assets/icon/app_icon.png').existsSync(), isTrue);
    expect(File('assets/icon/app_icon_fg.png').existsSync(), isTrue);
  });
}
