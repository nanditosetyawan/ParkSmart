// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

/// Implementasi unduh file untuk platform Web Chrome/browser
Future<String?> downloadBytesFile(Uint8List bytes, String filename) async {
  try {
    final base64String = base64Encode(bytes);
    final href = 'data:image/png;base64,$base64String';
    final anchor = html.AnchorElement(href: href)
      ..target = 'blank'
      ..download = filename;

    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    return filename;
  } catch (e) {
    return null;
  }
}
