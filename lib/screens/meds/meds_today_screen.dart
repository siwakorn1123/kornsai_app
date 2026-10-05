import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicine_item.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../home/notifications_sheet.dart';
import 'add_medicine_screen.dart';

class MedsTodayScreen extends StatefulWidget {
  const MedsTodayScreen({super.key});

  @override
  State<MedsTodayScreen> createState() => _MedsTodayScreenState();
}

class _MedsTodayScreenState extends State<MedsTodayScreen> {
  final Map<String, bool> _snoozedSlots = {};
  bool _isCaregiverView = false; // Toggle Remote Care view (ลูกหลานเห็นจากระยะไกล)

  void _toggleSnooze(String slotKey) {
    setState(() {
      _snoozedSlots[slotKey] = !(_snoozedSlots[slotKey] ?? false);
    });
    if (_snoozedSlots[slotKey] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏰ เลื่อนเตือนไปอีก 30 นาที'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
    }
  }

  void _showRemoteCareModal(BuildContext context) {
    setState(() {
      _isCaregiverView = true;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0DDD5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1EB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text('👨‍👩‍👦', style: TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ลูกหลานเห็นจากระยะไกล',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      Text(
                        'Remote Care Monitoring',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFECC4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'การแจ้งเตือนถึงลูกหลาน (คุณอาร์ต):',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '⚠️ "คุณแม่สมศรียังไม่ได้กดยืนยันมื้อยา 20:00 (ยาความดัน) เกินเวลามา 15 นาทีแล้ว"',
                    style: TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('📞 กำลังต่อสายโทรหาคุณแม่สมศรี...'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                          icon: const Icon(Icons.phone, color: Colors.white, size: 18),
                          label: const Text('โทรเตือนคุณแม่', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('💬 ส่งข้อความเตือนเข้า LINE คุณแม่แล้ว'),
                                backgroundColor: Color(0xFF06C755),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF06C755), size: 18),
                          label: const Text('ส่ง LINE', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE5E0D6)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '💡 จุดเด่นตาม Pitch Deck: ถ้าผู้สูงอายุไม่ได้กดยืนยัน ลูกหลานที่ผูกบัญชีไว้จะได้รับการแจ้งเตือนแทน และโทรไปเตือนได้ทันที',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showMedicineOptions(BuildContext context, MedicineItem med) {
    final appState = Provider.of<AppState>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💊', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('เหลือ ${med.totalPillsRemaining} ${med.doseUnit} (สำหรับ ${med.ownerName})',
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: AppColors.success),
              title: const Text('เติมสต็อกยา (+30 เม็ด)', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                med.totalPillsRemaining += 30;
                appState.updateMedicine(med);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('เติมยา "${med.name}" เป็น ${med.totalPillsRemaining} เม็ดแล้ว'),
                      backgroundColor: AppColors.success),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: const Text('แก้ไขตารางยา', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.danger),
              title: const Text('ลบรายการยานี้', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.danger)),
              onTap: () {
                appState.removeMedicine(med.id);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final slots = state.todayScheduledSlots;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ตารางยาวันนี้',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              'คุณแม่สมศรี · กิน ${state.todayCompletedMedsCount} จาก ${state.todayTotalMedsCount} มื้อ',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textDark),
            tooltip: 'การแจ้งเตือน',
            onPressed: () => NotificationsSheet.show(context),
          ),
          IconButton(
            icon: Icon(
              _isCaregiverView ? Icons.family_restroom : Icons.family_restroom_outlined,
              color: _isCaregiverView ? AppColors.primary : AppColors.textDark,
            ),
            tooltip: 'มุมมองลูกหลาน (Remote Care)',
            onPressed: () => _showRemoteCareModal(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Remote Care Banner Banner (Pitch deck page 6)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFECC4)),
              ),
              child: Row(
                children: [
                  const Text('👨‍👩‍👦', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'ลูกหลานเห็นจากระยะไกล: ผูกบัญชีกับคุณแม่แล้ว',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showRemoteCareModal(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFECC4)),
                      ),
                      child: const Text(
                        'ทดสอบเตือน',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content: Empty State or Scheduled Cards (Matching Page 6)
            Expanded(
              child: slots.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            alignment: Alignment.center,
                            child: const Text('💊', style: TextStyle(fontSize: 64)),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'ยังไม่ได้ตั้งตารางยา',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'กด ➕ ด้านล่างเพื่อเพิ่มยาประจำ',
                            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      itemCount: slots.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final slot = slots[index];
                        final isTaken = slot.isTaken;
                        final slotKey = '${slot.medicine.id}_${slot.time}';
                        final isSnoozed = _snoozedSlots[slotKey] ?? false;

                        return GestureDetector(
                          onTap: () => _showMedicineOptions(context, slot.medicine),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: !isTaken
                                  ? Border.all(color: const Color(0xFFFFECC4), width: 1.5)
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isTaken
                                            ? const Color(0xFFE8F5E9)
                                            : const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        isTaken ? '✓' : slot.medicine.emojiIcon,
                                        style: TextStyle(
                                          fontSize: isTaken ? 22 : 24,
                                          fontWeight: FontWeight.bold,
                                          color: isTaken ? AppColors.success : null,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${slot.medicine.name} · ${slot.medicine.doseAmount} ${slot.medicine.doseUnit}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Text(
                                                '${slot.time} · ${isTaken ? "กินแล้ว" : (isSnoozed ? "เลื่อน 30 น." : "ถึงเวลาแล้ว")}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: isTaken
                                                      ? AppColors.success
                                                      : (isSnoozed ? const Color(0xFFD97706) : AppColors.primary),
                                                ),
                                              ),
                                              const Text(' · ', style: TextStyle(color: AppColors.textSubtle)),
                                              Text(
                                                slot.medicine.timing.iconStr,
                                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isTaken)
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check, color: Colors.white, size: 18),
                                      )
                                    else
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFFD97706), width: 2),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),

                                // Action Buttons if not taken yet (Matching Page 6)
                                if (!isTaken) ...[
                                  const SizedBox(height: 14),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            state.toggleMedTaken(slot.medicine.id, slot.time);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('✅ บันทึกว่ากิน "${slot.medicine.name}" แล้ว'),
                                                backgroundColor: AppColors.success,
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.textDark,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          child: const Text(
                                            'กินแล้ว',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _toggleSnooze(slotKey),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Color(0xFFE5E0D6)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          child: Text(
                                            isSnoozed ? 'เลื่อนแล้ว' : 'เลื่อน 30 น.',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Footer summary bar (Matching Page 6: "ซ้ำทุกวัน · เหลือ 12 เม็ด | แก้ไขตาราง")
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEAE5DB))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(builder: (context) {
                    final totalRemaining = state.medicines.fold<int>(0, (sum, m) => sum + m.totalPillsRemaining);
                    return Row(
                      children: [
                        const Text('🔄', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          'ซ้ำทุกวัน · เหลือ $totalRemaining เม็ด',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ],
                    );
                  }),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
                      );
                    },
                    child: const Text(
                      'แก้ไขตาราง',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('เพิ่มยา', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
