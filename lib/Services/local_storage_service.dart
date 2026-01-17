import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // Timetable methods
  Future<void> saveTimetable(Map<String, dynamic> timetable) async {
    final prefs = await SharedPreferences.getInstance();
    final timetables = await getTimetables();
    timetable['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    timetables.add(timetable);
    await prefs.setString('timetables', jsonEncode(timetables));
  }

  Future<List<Map<String, dynamic>>> getTimetables() async {
    final prefs = await SharedPreferences.getInstance();
    final String? timetablesJson = prefs.getString('timetables');
    if (timetablesJson == null) return [];
    final List<dynamic> decoded = jsonDecode(timetablesJson);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> updateTimetable(String id, Map<String, dynamic> timetable) async {
    final prefs = await SharedPreferences.getInstance();
    final timetables = await getTimetables();
    final index = timetables.indexWhere((t) => t['id'] == id);
    if (index >= 0) {
      timetables[index] = {...timetable, 'id': id};
      await prefs.setString('timetables', jsonEncode(timetables));
    }
  }

  Future<void> deleteTimetable(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final timetables = await getTimetables();
    timetables.removeWhere((t) => t['id'] == id);
    await prefs.setString('timetables', jsonEncode(timetables));
  }

  // Reminder methods
  Future<void> saveReminder(Map<String, dynamic> reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = await getReminders();
    reminder['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    reminders.add(reminder);
    await prefs.setString('reminders', jsonEncode(reminders));
  }

  Future<List<Map<String, dynamic>>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? remindersJson = prefs.getString('reminders');
    if (remindersJson == null) return [];
    final List<dynamic> decoded = jsonDecode(remindersJson);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> updateReminder(String id, Map<String, dynamic> reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = await getReminders();
    final index = reminders.indexWhere((r) => r['id'] == id);
    if (index >= 0) {
      reminders[index] = {...reminder, 'id': id};
      await prefs.setString('reminders', jsonEncode(reminders));
    }
  }

  Future<void> deleteReminder(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = await getReminders();
    reminders.removeWhere((r) => r['id'] == id);
    await prefs.setString('reminders', jsonEncode(reminders));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('timetables');
    await prefs.remove('reminders');
  }
}
