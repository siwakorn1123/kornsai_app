import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ItemCategory {
  food('อาหาร', '🍎'),
  medicine('ยา/เวชภัณฑ์', '💊'),
  document('เอกสาร/ประกัน', '📄'),
  other('อื่นๆ', '📦');

  final String label;
  final String emoji;
  const ItemCategory(this.label, this.emoji);

  static ItemCategory fromString(String val) {
    return ItemCategory.values.firstWhere(
      (e) => e.name == val || e.label == val,
      orElse: () => ItemCategory.food,
    );
  }
}

class PantryItem {
  final String id;
  String name;
  String emojiIcon;
  ItemCategory category;
  DateTime expiryDate;
  DateTime addedDate;
  int quantity;
  String unit;
  String location;
  bool isFinished;
  bool isDiscarded;
  String? barcode;
  String? sourceTag; // e.g. 'อ่านวันจากบาร์โค้ด 2D', 'ยืนยันวันที่แล้ว'

  PantryItem({
    required this.id,
    required this.name,
    this.emojiIcon = '🍎',
    this.category = ItemCategory.food,
    required this.expiryDate,
    DateTime? addedDate,
    this.quantity = 1,
    this.unit = 'ชิ้น',
    this.location = 'ตู้เย็น',
    this.isFinished = false,
    this.isDiscarded = false,
    this.barcode,
    this.sourceTag,
  }) : addedDate = addedDate ?? DateTime.now();

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return target.difference(today).inDays;
  }

  bool get isExpired => daysRemaining < 0;
  bool get isExpiringSoon => daysRemaining >= 0 && daysRemaining <= 3;
  bool get isSafe => daysRemaining > 3;

  String get statusBadgeText {
    if (daysRemaining < 0) {
      return 'หมดแล้ว';
    } else if (daysRemaining == 0) {
      return 'หมดวันนี้';
    } else if (daysRemaining == 1) {
      return '1 วัน';
    } else if (daysRemaining <= 7) {
      return '$daysRemaining วัน';
    } else if (daysRemaining <= 30) {
      final weeks = (daysRemaining / 7).round();
      return '$weeks สัปดาห์';
    } else {
      final months = (daysRemaining / 30).round();
      return '$months เดือน';
    }
  }

  Color get statusBadgeColor {
    if (isExpired) return AppColors.danger;
    if (isExpiringSoon) return AppColors.warning;
    return AppColors.success;
  }

  Color get statusBadgeBgColor {
    if (isExpired) return AppColors.dangerBg;
    if (isExpiringSoon) return AppColors.warningBg;
    return AppColors.successBg;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emojiIcon': emojiIcon,
        'category': category.name,
        'expiryDate': expiryDate.toIso8601String(),
        'addedDate': addedDate.toIso8601String(),
        'quantity': quantity,
        'unit': unit,
        'location': location,
        'isFinished': isFinished,
        'isDiscarded': isDiscarded,
        'barcode': barcode,
        'sourceTag': sourceTag,
      };

  factory PantryItem.fromJson(Map<String, dynamic> json) => PantryItem(
        id: json['id'],
        name: json['name'],
        emojiIcon: json['emojiIcon'] ?? '🍎',
        category: ItemCategory.fromString(json['category'] ?? 'food'),
        expiryDate: DateTime.parse(json['expiryDate']),
        addedDate: json['addedDate'] != null ? DateTime.parse(json['addedDate']) : null,
        quantity: json['quantity'] ?? 1,
        unit: json['unit'] ?? 'ชิ้น',
        location: json['location'] ?? 'ตู้เย็น',
        isFinished: json['isFinished'] ?? false,
        isDiscarded: json['isDiscarded'] ?? false,
        barcode: json['barcode'],
        sourceTag: json['sourceTag'],
      );
}
