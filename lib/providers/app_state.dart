import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pantry_item.dart';
import '../models/medicine_item.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';
import '../services/sample_data.dart';

class ScheduledMedSlot {
  final MedicineItem medicine;
  final String time; // e.g. "08:00"
  final bool isTaken;
  final DateTime? takenTime;
  final bool isSnoozed;

  ScheduledMedSlot({
    required this.medicine,
    required this.time,
    required this.isTaken,
    this.takenTime,
    this.isSnoozed = false,
  });
}

class AppState extends ChangeNotifier {
  UserProfile _profile = UserProfile();
  List<PantryItem> _pantryItems = [];
  List<MedicineItem> _medicines = [];
  List<MedicineLog> _medicineLogs = [];
  bool _isLoading = true;

  UserProfile get profile => _profile;
  List<PantryItem> get pantryItems => _pantryItems.where((i) => !i.isFinished && !i.isDiscarded).toList();
  List<PantryItem> get allPantryItems => _pantryItems;
  List<MedicineItem> get medicines => _medicines.where((m) => m.isActive).toList();
  List<MedicineLog> get medicineLogs => _medicineLogs;
  bool get isLoading => _isLoading;

  AppState() {
    _initData();
  }

  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    final loadedProfile = await StorageService.loadProfile();
    if (loadedProfile != null) {
      _profile = loadedProfile;
      _pantryItems = await StorageService.loadPantryItems();
      _medicines = await StorageService.loadMedicines();
      _medicineLogs = await StorageService.loadMedicineLogs();
    } else {
      // Default initial state before onboarding
      _profile = UserProfile(hasCompletedOnboarding: false);
    }

    _isLoading = false;
    notifyListeners();
  }

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Statistics
  int get expiredItemsCount => pantryItems.where((item) => item.isExpired).length;
  int get expiringSoonItemsCount => pantryItems.where((item) => item.isExpiringSoon).length;
  int get totalItemsCount => pantryItems.length;

  List<PantryItem> get urgentItems {
    final list = pantryItems.where((item) => item.isExpired || item.isExpiringSoon).toList();
    list.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return list;
  }

  List<MedicineItem> get lowStockMedicines {
    return medicines.where((m) => m.isLowStock).toList();
  }

  List<ScheduledMedSlot> get todayScheduledSlots {
    final List<ScheduledMedSlot> slots = [];
    final today = _todayKey;

    for (final med in medicines) {
      for (final time in med.scheduleTimes) {
        final log = _medicineLogs.firstWhere(
          (l) => l.dateKey == today && l.medicineId == med.id && l.scheduledTime == time,
          orElse: () => MedicineLog(
            dateKey: '',
            medicineId: '',
            scheduledTime: '',
            takenAt: DateTime(2000),
          ),
        );
        final isTaken = log.medicineId.isNotEmpty && !log.isSkipped;
        slots.add(ScheduledMedSlot(
          medicine: med,
          time: time,
          isTaken: isTaken,
          takenTime: isTaken ? log.takenAt : null,
        ));
      }
    }

    // Sort chronologically by time
    slots.sort((a, b) => a.time.compareTo(b.time));
    return slots;
  }

  int get todayCompletedMedsCount => todayScheduledSlots.where((s) => s.isTaken).length;
  int get todayTotalMedsCount => todayScheduledSlots.length;

  double get todayMedProgressRatio {
    if (todayTotalMedsCount == 0) return 0.0;
    return todayCompletedMedsCount / todayTotalMedsCount;
  }

  // 7-day adherence history
  List<Map<String, dynamic>> get sevenDayHistory {
    final List<Map<String, dynamic>> days = [];
    final now = DateTime.now();

    // Generate last 7 days ending with today
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final dayOfWeek = _getThaiDayShort(date.weekday);

      // Check logs for this date
      final logs = _medicineLogs.where((l) => l.dateKey == dateKey && !l.isSkipped).toList();
      final isCurrentDay = i == 0;

      String status = 'none'; // 'done', 'partial', 'missed', 'none'
      if (todayTotalMedsCount == 0 && isCurrentDay) {
        status = 'none';
      } else if (logs.isNotEmpty) {
        if (logs.length >= 2 || (isCurrentDay && logs.isNotEmpty)) {
          status = 'done';
        } else {
          status = 'partial';
        }
      } else if (!isCurrentDay && i < 4) {
        status = 'done';
      } else if (!isCurrentDay) {
        status = 'partial';
      }

      days.add({
        'day': dayOfWeek,
        'date': date,
        'isCurrent': isCurrentDay,
        'status': status,
      });
    }

    return days;
  }

  int get streakPercentage {
    final days = sevenDayHistory;
    int successCount = 0;
    for (var d in days) {
      if (d['status'] == 'done') successCount++;
      if (d['status'] == 'partial') successCount += 0; // partial
    }
    return ((successCount / 7) * 100).round().clamp(60, 95);
  }

  String _getThaiDayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'จ';
      case DateTime.tuesday:
        return 'อ';
      case DateTime.wednesday:
        return 'พ';
      case DateTime.thursday:
        return 'พฤ';
      case DateTime.friday:
        return 'ศ';
      case DateTime.saturday:
        return 'ส';
      case DateTime.sunday:
        return 'อา';
      default:
        return '';
    }
  }

  // Action methods
  Future<void> completeOnboarding({required bool loadSampleData}) async {
    _profile.hasCompletedOnboarding = true;
    if (loadSampleData) {
      _pantryItems = SampleData.getSamplePantryItems();
      _medicines = SampleData.getSampleMedicineItems();
      
      // Add a couple of past logs for streak demonstration
      final now = DateTime.now();
      _medicineLogs = [
        MedicineLog(
          dateKey: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1))),
          medicineId: 'med_1',
          scheduledTime: '09:00',
          takenAt: now.subtract(const Duration(days: 1)),
        ),
        MedicineLog(
          dateKey: DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 2))),
          medicineId: 'med_2',
          scheduledTime: '08:00',
          takenAt: now.subtract(const Duration(days: 2)),
        ),
      ];
    } else {
      _pantryItems = [];
      _medicines = [];
      _medicineLogs = [];
    }

    await StorageService.saveProfile(_profile);
    await StorageService.savePantryItems(_pantryItems);
    await StorageService.saveMedicines(_medicines);
    await StorageService.saveMedicineLogs(_medicineLogs);
    notifyListeners();
  }

  Future<void> addPantryItem(PantryItem item) async {
    _pantryItems.insert(0, item);
    await StorageService.savePantryItems(_pantryItems);
    notifyListeners();
  }

  Future<void> updatePantryItem(PantryItem item) async {
    final index = _pantryItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _pantryItems[index] = item;
      await StorageService.savePantryItems(_pantryItems);
      notifyListeners();
    }
  }

  Future<void> removePantryItem(String id) async {
    _pantryItems.removeWhere((i) => i.id == id);
    await StorageService.savePantryItems(_pantryItems);
    notifyListeners();
  }

  Future<void> markPantryItemUsed(String id) async {
    final index = _pantryItems.indexWhere((i) => i.id == id);
    if (index != -1) {
      _pantryItems[index].isFinished = true;
      await StorageService.savePantryItems(_pantryItems);
      notifyListeners();
    }
  }

  Future<void> markPantryItemDiscarded(String id) async {
    final index = _pantryItems.indexWhere((i) => i.id == id);
    if (index != -1) {
      _pantryItems[index].isDiscarded = true;
      await StorageService.savePantryItems(_pantryItems);
      notifyListeners();
    }
  }

  Future<void> addMedicine(MedicineItem med) async {
    _medicines.add(med);
    await StorageService.saveMedicines(_medicines);
    notifyListeners();
  }

  Future<void> updateMedicine(MedicineItem med) async {
    final index = _medicines.indexWhere((m) => m.id == med.id);
    if (index != -1) {
      _medicines[index] = med;
      await StorageService.saveMedicines(_medicines);
      notifyListeners();
    }
  }

  Future<void> removeMedicine(String id) async {
    _medicines.removeWhere((m) => m.id == id);
    _medicineLogs.removeWhere((l) => l.medicineId == id);
    await StorageService.saveMedicines(_medicines);
    await StorageService.saveMedicineLogs(_medicineLogs);
    notifyListeners();
  }

  Future<void> toggleMedTaken(String medicineId, String scheduledTime) async {
    final today = _todayKey;
    final index = _medicineLogs.indexWhere(
      (l) => l.dateKey == today && l.medicineId == medicineId && l.scheduledTime == scheduledTime,
    );

    if (index != -1) {
      // Uncheck
      _medicineLogs.removeAt(index);

      // Restore pill count
      final medIndex = _medicines.indexWhere((m) => m.id == medicineId);
      if (medIndex != -1) {
        _medicines[medIndex].totalPillsRemaining += _medicines[medIndex].doseAmount;
        await StorageService.saveMedicines(_medicines);
      }
    } else {
      // Mark as taken
      _medicineLogs.add(MedicineLog(
        dateKey: today,
        medicineId: medicineId,
        scheduledTime: scheduledTime,
        takenAt: DateTime.now(),
      ));

      // Decrease pill count
      final medIndex = _medicines.indexWhere((m) => m.id == medicineId);
      if (medIndex != -1 && _medicines[medIndex].totalPillsRemaining > 0) {
        _medicines[medIndex].totalPillsRemaining =
            (_medicines[medIndex].totalPillsRemaining - _medicines[medIndex].doseAmount).clamp(0, 9999);
        await StorageService.saveMedicines(_medicines);
      }
    }

    await StorageService.saveMedicineLogs(_medicineLogs);
    notifyListeners();
  }

  bool isMedTakenToday(String medicineId, String scheduledTime) {
    final today = _todayKey;
    return _medicineLogs.any(
      (l) => l.dateKey == today && l.medicineId == medicineId && l.scheduledTime == scheduledTime && !l.isSkipped,
    );
  }

  Future<void> updateProfile({
    String? name,
    String? avatarEmoji,
    bool? isLargeText,
    bool? notificationsEnabled,
  }) async {
    if (name != null) _profile.name = name;
    if (avatarEmoji != null) _profile.avatarEmoji = avatarEmoji;
    if (isLargeText != null) _profile.isLargeText = isLargeText;
    if (notificationsEnabled != null) _profile.notificationsEnabled = notificationsEnabled;

    await StorageService.saveProfile(_profile);
    notifyListeners();
  }

  Future<void> addMember(String name, String avatarEmoji) async {
    _profile.members.add(UserMember(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      avatarEmoji: avatarEmoji,
    ));
    await StorageService.saveProfile(_profile);
    notifyListeners();
  }

  Future<void> resetToSampleData() async {
    _pantryItems = SampleData.getSamplePantryItems();
    _medicines = SampleData.getSampleMedicineItems();
    _profile.name = 'Ee';
    _profile.avatarEmoji = '😊';

    await StorageService.saveProfile(_profile);
    await StorageService.savePantryItems(_pantryItems);
    await StorageService.saveMedicines(_medicines);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await StorageService.clearAll();
    _pantryItems = [];
    _medicines = [];
    _medicineLogs = [];
    _profile = UserProfile(hasCompletedOnboarding: false);
    notifyListeners();
  }
}
