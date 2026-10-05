enum MedicineTiming {
  beforeMeal('ก่อนอาหาร', '💊➔🍽️'),
  afterMeal('หลังอาหาร', '🍽️➔💊'),
  withMeal('พร้อมอาหาร', '🍽️💊'),
  beforeBed('ก่อนนอน', '🌙'),
  exactTime('ตามเวลา', '⏰');

  final String label;
  final String iconStr;
  const MedicineTiming(this.label, this.iconStr);

  static MedicineTiming fromString(String val) {
    return MedicineTiming.values.firstWhere(
      (e) => e.name == val || e.label == val,
      orElse: () => MedicineTiming.afterMeal,
    );
  }
}

class MedicineItem {
  final String id;
  String name;
  String emojiIcon;
  String ownerName;
  String ownerAvatar;
  int doseAmount;
  String doseUnit; // เม็ด, แคปซูล, ช้อนชา, หยด, ซอง
  MedicineTiming timing;
  List<String> scheduleTimes; // e.g. ["08:00", "21:00"]
  int totalPillsRemaining;
  int alertThreshold;
  bool isActive;

  MedicineItem({
    required this.id,
    required this.name,
    this.emojiIcon = '💊',
    this.ownerName = 'ฉัน',
    this.ownerAvatar = '😊',
    this.doseAmount = 1,
    this.doseUnit = 'เม็ด',
    this.timing = MedicineTiming.afterMeal,
    required this.scheduleTimes,
    this.totalPillsRemaining = 30,
    this.alertThreshold = 5,
    this.isActive = true,
  });

  bool get isLowStock => totalPillsRemaining <= alertThreshold;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emojiIcon': emojiIcon,
        'ownerName': ownerName,
        'ownerAvatar': ownerAvatar,
        'doseAmount': doseAmount,
        'doseUnit': doseUnit,
        'timing': timing.name,
        'scheduleTimes': scheduleTimes,
        'totalPillsRemaining': totalPillsRemaining,
        'alertThreshold': alertThreshold,
        'isActive': isActive,
      };

  factory MedicineItem.fromJson(Map<String, dynamic> json) => MedicineItem(
        id: json['id'],
        name: json['name'],
        emojiIcon: json['emojiIcon'] ?? '💊',
        ownerName: json['ownerName'] ?? 'ฉัน',
        ownerAvatar: json['ownerAvatar'] ?? '😊',
        doseAmount: json['doseAmount'] ?? 1,
        doseUnit: json['doseUnit'] ?? 'เม็ด',
        timing: MedicineTiming.fromString(json['timing'] ?? 'afterMeal'),
        scheduleTimes: List<String>.from(json['scheduleTimes'] ?? ['08:00']),
        totalPillsRemaining: json['totalPillsRemaining'] ?? 30,
        alertThreshold: json['alertThreshold'] ?? 5,
        isActive: json['isActive'] ?? true,
      );
}

class MedicineLog {
  final String dateKey; // YYYY-MM-DD
  final String medicineId;
  final String scheduledTime; // e.g. "08:00"
  final DateTime takenAt;
  final bool isSkipped;

  MedicineLog({
    required this.dateKey,
    required this.medicineId,
    required this.scheduledTime,
    required this.takenAt,
    this.isSkipped = false,
  });

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'medicineId': medicineId,
        'scheduledTime': scheduledTime,
        'takenAt': takenAt.toIso8601String(),
        'isSkipped': isSkipped,
      };

  factory MedicineLog.fromJson(Map<String, dynamic> json) => MedicineLog(
        dateKey: json['dateKey'],
        medicineId: json['medicineId'],
        scheduledTime: json['scheduledTime'],
        takenAt: DateTime.parse(json['takenAt']),
        isSkipped: json['isSkipped'] ?? false,
      );
}
