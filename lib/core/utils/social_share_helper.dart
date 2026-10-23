import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SocialShareHelper {
  /// Captures any widget wrapped in a RepaintBoundary and shares it as an image
  static Future<bool> captureAndShare({
    required GlobalKey boundaryKey,
    required String text,
    String? subject,
  }) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return false;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return false;

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/mineai_hype_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: text,
          subject: subject,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('[SocialShareHelper] Error sharing image: $e');
      return false;
    }
  }
}
