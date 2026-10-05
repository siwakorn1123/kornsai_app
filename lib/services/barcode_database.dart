import '../models/pantry_item.dart';

class ScannedProduct {
  final String barcode;
  final String name;
  final ItemCategory category;
  final String emojiIcon;
  final int defaultExpiryDays;
  final String location;
  final String unit;

  const ScannedProduct({
    required this.barcode,
    required this.name,
    required this.category,
    required this.emojiIcon,
    required this.defaultExpiryDays,
    this.location = 'ตู้เย็น',
    this.unit = 'ชิ้น',
  });
}

class BarcodeDatabase {
  static final List<ScannedProduct> presetProducts = [
    const ScannedProduct(
      barcode: '8850123456789',
      name: 'นมพาสเจอร์ไรส์ 1 ล.',
      category: ItemCategory.food,
      emojiIcon: '🥛',
      defaultExpiryDays: 3,
      location: 'ตู้เย็น',
      unit: 'ขวด',
    ),
    const ScannedProduct(
      barcode: '8850987654321',
      name: 'แซนด์วิชทูน่า',
      category: ItemCategory.food,
      emojiIcon: '🍱',
      defaultExpiryDays: 2,
      location: 'ตู้เย็น',
      unit: 'ชิ้น',
    ),
    const ScannedProduct(
      barcode: '8851122334455',
      name: 'ข้าวกล่องไก่ทอด 7-11',
      category: ItemCategory.food,
      emojiIcon: '🍱',
      defaultExpiryDays: 2,
      location: 'ตู้เย็น',
      unit: 'กล่อง',
    ),
    const ScannedProduct(
      barcode: '8855544332211',
      name: 'ไข่ไก่สด Betagro (10 ฟอง)',
      category: ItemCategory.food,
      emojiIcon: '🥚',
      defaultExpiryDays: 14,
      location: 'ตู้เย็น',
      unit: 'แพ็ค',
    ),
    const ScannedProduct(
      barcode: '8857766554433',
      name: 'ขนมปังโฮลวีต ฟาร์มเฮ้าส์',
      category: ItemCategory.food,
      emojiIcon: '🍞',
      defaultExpiryDays: 4,
      location: 'โต๊ะอาหาร',
      unit: 'แถว',
    ),
    const ScannedProduct(
      barcode: '8859988776655',
      name: 'โยเกิร์ตรสธรรมชาติ ดัชชี่',
      category: ItemCategory.food,
      emojiIcon: '🍦',
      defaultExpiryDays: 10,
      location: 'ตู้เย็น',
      unit: 'ถ้วย',
    ),
    const ScannedProduct(
      barcode: '8854433221100',
      name: 'วิตามินซี Vistra 1000mg',
      category: ItemCategory.medicine,
      emojiIcon: '💊',
      defaultExpiryDays: 365,
      location: 'ตู้ยา',
      unit: 'ขวด',
    ),
    const ScannedProduct(
      barcode: '8853322110099',
      name: 'ยาพาราเซตามอล ซาร่า 500mg',
      category: ItemCategory.medicine,
      emojiIcon: '💊',
      defaultExpiryDays: 730,
      location: 'ตู้ยา',
      unit: 'แผง',
    ),
  ];

  static ScannedProduct? lookup(String barcode) {
    try {
      return presetProducts.firstWhere((p) => p.barcode == barcode.trim());
    } catch (_) {
      return null;
    }
  }
}
