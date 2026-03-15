import 'package:shared_preferences/shared_preferences.dart';

class InvoiceNumberGenerator {
  static Future<String> generateInvoiceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final finYearStart = now.month < 4 ? now.year - 1 : now.year;
    final finYearEnd = finYearStart + 1;
    final finYearKey = 'seq_$finYearStart-$finYearEnd';
    int seq = prefs.getInt(finYearKey) ?? 0;
    seq++;
    await prefs.setInt(finYearKey, seq);
    final finYearStr = '${finYearStart.toString().substring(2)}-${finYearEnd.toString().substring(2)}';
    return 'I/$finYearStr/${seq.toString().padLeft(6, '0')}';
  }
}