import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/subject.dart';

class DBService {
  static const String _boxName = 'studycraft_box';

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  static Future<void> saveSubjects(List<Subject> subjects) async {
    final box = await Hive.openBox(_boxName);
    String jsonData = jsonEncode(subjects.map((s) => s.toJson()).toList());
    await box.put('subjects', jsonData);
    await box.close();
  }

  static Future<List<Subject>> loadSubjects() async {
    final box = await Hive.openBox(_boxName);
    String? jsonData = box.get('subjects');
    await box.close();
    if (jsonData == null) return [];
    List decoded = jsonDecode(jsonData);
    return decoded.map((e) => Subject.fromJson(e)).toList();
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final box = await Hive.openBox(_boxName);
    String jsonData = jsonEncode(settings);
    await box.put('settings', jsonData);
    await box.close();
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    final box = await Hive.openBox(_boxName);
    String? jsonData = box.get('settings');
    await box.close();
    if (jsonData == null) return {};
    return jsonDecode(jsonData);
  }

  static Future<void> exportData() async {
    // Later: Allow export to file
  }

  static Future<void> importData(String jsonData) async {
    // Later: Allow import from file
  }
}
