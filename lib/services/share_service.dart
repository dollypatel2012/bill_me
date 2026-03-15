import 'dart:io';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> sharePdf(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'Invoice');
  }
}