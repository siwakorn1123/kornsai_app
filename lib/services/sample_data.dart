import '../models/pantry_item.dart';
import '../models/medicine_item.dart';

class SampleData {
  static List<PantryItem> getSamplePantryItems() {
    final now = DateTime.now();

    return [
      PantryItem(
        id: 'item_1',
        name: 'ข้าวกล่องไก่ทอด 7-11',
        emojiIcon: '🍱',
        category: ItemCategory.food,
        expiryDate: DateTime(now.year, now.month, now.day, 18, 0), // Expiring today
        location: 'ตู้เย็น',
        quantity: 1,
        unit: 'กล่อง',
        sourceTag: 'อ่านวันจากบาร์โค้ด 2D',
      ),
      PantryItem(
        id: 'item_2',
        name: 'นมสดพาสเจอร์ไรส์ 1 ล.',
        emojiIcon: '🥛',
        category: ItemCategory.food,
        expiryDate: now.add(const Duration(days: 1)),
        location: 'ตู้เย็น',
        quantity: 1,
        unit: 'ขวด',
        sourceTag: 'ยืนยันวันที่แล้ว',
      ),
      PantryItem(
        id: 'item_3',
        name: 'ไข่ไก่สด Betagro',
        emojiIcon: '🥚',
        category: ItemCategory.food,
        expiryDate: now.add(const Duration(days: 14)),
        location: 'ตู้เย็น',
        quantity: 10,
        unit: 'ฟอง',
        sourceTag: 'คำแนะนำเริ่มต้น',
      ),
      PantryItem(
        id: 'item_4',
        name: 'ขนมปังโฮลวีต ฟาร์มเฮ้าส์',
        emojiIcon: '🍞',
        category: ItemCategory.food,
        expiryDate: now.add(const Duration(days: 3)),
        location: 'โต๊ะอาหาร',
        quantity: 1,
        unit: 'แถว',
        sourceTag: 'คำแนะนำเริ่มต้น',
      ),
      PantryItem(
        id: 'item_5',
        name: 'โยเกิร์ตสตอเบอร์รี่ ดัชชี่',
        emojiIcon: '🍦',
        category: ItemCategory.food,
        expiryDate: now.add(const Duration(days: 7)),
        location: 'ตู้เย็น',
        quantity: 2,
        unit: 'ถ้วย',
        sourceTag: 'คำแนะนำเริ่มต้น',
      ),
      PantryItem(
        id: 'item_6',
        name: 'พาราเซตามอล ซาร่า 500mg',
        emojiIcon: '💊',
        category: ItemCategory.medicine,
        expiryDate: now.add(const Duration(days: 340)),
        location: 'ตู้ยา',
        quantity: 20,
        unit: 'เม็ด',
        sourceTag: 'ตู้ยาประจำบ้าน',
      ),
      PantryItem(
        id: 'item_7',
        name: 'ประกันรถยนต์',
        emojiIcon: '📄',
        category: ItemCategory.document,
        expiryDate: now.add(const Duration(days: 45)),
        location: 'ลิ้นชักเอกสาร',
        quantity: 1,
        unit: 'ฉบับ',
        sourceTag: 'ครบกำหนด 1 พ.ย. 2569',
      ),
    ];
  }

  static List<MedicineItem> getSampleMedicineItems() {
    return [
      MedicineItem(
        id: 'med_1',
        name: 'ยาความดัน',
        emojiIcon: '💊',
        ownerName: 'คุณแม่สมศรี',
        ownerAvatar: '👵',
        doseAmount: 1,
        doseUnit: 'เม็ด',
        timing: MedicineTiming.afterMeal,
        scheduleTimes: ['08:00', '20:00'],
        totalPillsRemaining: 12,
        alertThreshold: 5,
        isActive: true,
      ),
      MedicineItem(
        id: 'med_2',
        name: 'ยาเบาหวาน',
        emojiIcon: '💊',
        ownerName: 'คุณแม่สมศรี',
        ownerAvatar: '👵',
        doseAmount: 1,
        doseUnit: 'เม็ด',
        timing: MedicineTiming.beforeMeal,
        scheduleTimes: ['12:30'],
        totalPillsRemaining: 14,
        alertThreshold: 5,
        isActive: true,
      ),
      MedicineItem(
        id: 'med_3',
        name: 'ยาแก้แพ้',
        emojiIcon: '💊',
        ownerName: 'คุณแม่สมศรี',
        ownerAvatar: '👵',
        doseAmount: 1,
        doseUnit: 'เม็ด',
        timing: MedicineTiming.beforeBed,
        scheduleTimes: ['21:30'],
        totalPillsRemaining: 4, // Triggers "เหลือ 4 วัน เตรียมซื้อใหม่"
        alertThreshold: 5,
        isActive: true,
      ),
    ];
  }
}
