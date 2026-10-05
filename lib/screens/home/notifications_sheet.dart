import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';

class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const NotificationsSheet(),
    );
  }

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  bool _isMedsTaken = false;
  bool _isSnoozed = false;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
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
          const SizedBox(height: 16),

          // Header (Matching Pitch Deck Page 5)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'การแจ้งเตือน',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Notification Cards
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                // Notification 1: ข้าวกล่องในตู้เย็น (วันนี้ 08:00)
                _buildNotificationCard(
                  timeText: 'วันนี้ 08:00',
                  title: 'ข้าวกล่องในตู้เย็นหมดอายุ 18:00 วันนี้ กินก่อนได้เลย',
                  iconEmoji: '🍱',
                  badgeColor: const Color(0xFFD92D20),
                  tag: 'ของหมดอายุ',
                ),
                const SizedBox(height: 12),

                // Notification 2: ถึงเวลากินยาความดัน (วันนี้ 20:00 · ซ้ำทุกวัน)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFECC4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Text('💊', style: TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'วันนี้ 20:00 · ซ้ำทุกวัน',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD97706)),
                                ),
                                Text(
                                  'ถึงเวลากินยาความดันของคุณแม่ 1 เม็ด',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isMedsTaken = true;
                                  _isSnoozed = false;
                                });
                                state.toggleMedTaken('med_1', '20:00');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ บันทึกว่าคุณแม่กินยาความดันเรียบร้อยแล้ว'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isMedsTaken ? const Color(0xFF1F5C40) : AppColors.textDark,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: Text(
                                _isMedsTaken ? '✓ กินแล้ว' : 'กินแล้ว',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isSnoozed = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('⏰ เลื่อนเตือนยาไปอีก 30 นาที'),
                                    backgroundColor: Color(0xFFD97706),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE5E0D6)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: Text(
                                _isSnoozed ? 'เลื่อนแล้ว (+30น.)' : 'เลื่อน 30 น.',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Notification 3: ยาแก้แพ้ของแม่เหลือ 4 วัน (เมื่อวาน 20:00)
                _buildNotificationCard(
                  timeText: 'เมื่อวาน 20:00',
                  title: 'ยาแก้แพ้ของแม่เหลือ 4 วัน เตรียมซื้อใหม่',
                  iconEmoji: '⚠️',
                  badgeColor: const Color(0xFFD97706),
                  tag: 'ยาใกล้หมด',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Bottom Settings link: "เตือนล่วงหน้า 3 วัน | แก้ไข" (Matching Pitch Deck Page 5)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('⚙️', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text(
                    'เตือนล่วงหน้า 3 วัน',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ตั้งค่าระบบแจ้งเตือนเรียบร้อยแล้ว')),
                  );
                },
                child: const Text(
                  'แก้ไข',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String timeText,
    required String title,
    required String iconEmoji,
    required Color badgeColor,
    required String tag,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAE5DB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5EE),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(iconEmoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeText,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
