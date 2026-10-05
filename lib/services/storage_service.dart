import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pantry_item.dart';
import '../models/medicine_item.dart';
import '../models/user_profile.dart';

class StorageService {
  static const String keyProfile = 'kornsai_profile';
  static const String keyPantry = 'kornsai_pantry_items';
  static const String keyMeds = 'kornsai_med_items';
  static const String keyLogs = 'kornsai_med_logs';

  static Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyProfile);
    if (jsonStr == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyProfile, jsonEncode(profile.toJson()));
  }

  static Future<List<PantryItem>> loadPantryItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyPantry);
    if (jsonStr == null) return [];
    try {
      final List list = jsonDecode(jsonStr);
      return list.map((e) => PantryItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> savePantryItems(List<PantryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((e) => e.toJson()).toList();
    await prefs.setString(keyPantry, jsonEncode(list));
  }

  static Future<List<MedicineItem>> loadMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyMeds);
    if (jsonStr == null) return [];
    try {
      final List list = jsonDecode(jsonStr);
      return list.map((e) => MedicineItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveMedicines(List<MedicineItem> meds) async {
    final prefs = await SharedPreferences.getInstance();
    final list = meds.map((e) => e.toJson()).toList();
    await prefs.setString(keyMeds, jsonEncode(list));
  }

  static Future<List<MedicineLog>> loadMedicineLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyLogs);
    if (jsonStr == null) return [];
    try {
      final List list = jsonDecode(jsonStr);
      return list.map((e) => MedicineLog.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveMedicineLogs(List<MedicineLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final list = logs.map((e) => e.toJson()).toList();
    await prefs.setString(keyLogs, jsonEncode(list));
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
