import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  /// Get file reference based on filename (default: calls.json)
  static Future<File> _getFile({String fileName = "calls.json"}) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  /// Save a new record (call or visit)
  static Future<void> saveRecord(Map<String, dynamic> data,
      {String fileName = "calls.json"}) async {
    final file = await _getFile(fileName: fileName);

    List<Map<String, dynamic>> records = [];

    if (await file.exists()) {
      String content = await file.readAsString();
      if (content.isNotEmpty) {
        records = List<Map<String, dynamic>>.from(jsonDecode(content));
      }
    }

    records.add(data);
    await file.writeAsString(jsonEncode(records));
  }

  /// Load all records (calls or visits)
  static Future<List<Map<String, dynamic>>> loadRecords(
      {String fileName = "calls.json"}) async {
    final file = await _getFile(fileName: fileName);

    if (!await file.exists()) return [];

    String content = await file.readAsString();
    if (content.isEmpty) return [];

    return List<Map<String, dynamic>>.from(jsonDecode(content));
  }
}
