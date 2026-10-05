import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pantry_item.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../meds/add_medicine_screen.dart';
import '../pantry/add_item_screen.dart';
import '../scanner/barcode_scanner_screen.dart';
import 'notifications_sheet.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  String _getThaiCurrentDate() {
    final now = DateTime.now();
    final dayNames = [
      'วันจันทร์', 'วันอังคาร', 'วันพุธ', 'วันพฤหัสบดี', 'วันศุกร์', 'วันเสาร์', 'วันอาทิตย์'
    ];
    final monthNames = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    final dayName = dayNames[now.weekday - 1];
    final monthName = monthNames[now.month - 1];
    return '🌅 $dayNameที่ ${now.day} $monthName';
  }

  void _showItemActionDialog(BuildContext context, PantryItem item) {
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
          children: [
            Row(
              children: [
                Text(item.emojiIcon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        'สถานะ: ${item.isExpired ? "หมดอายุแล้ว" : "เหลืออีก ${item.statusBadgeText}"}',
                        style: TextStyle(color: item.statusBadgeColor, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Text('✅', style: TextStyle(fontSize: 22)),
              title: const Text('ใช้หมดแล้ว', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                appState.markPantryItemUsed(item.id);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Text('🗑️', style: TextStyle(fontSize: 22)),
              title: const Text('ทิ้งแล้ว', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
              onTap: () {
                appState.markPantryItemDiscarded(item.id);
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
    final profile = state.profile;
    final urgentItems = state.urgentItems;
    final lowStockMeds = state.lowStockMedicines;
    final scheduledSlots = state.todayScheduledSlots;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header (Avatar, Date, Greeting, Notification Bell)
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFECC4), width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(profile.avatarEmoji, style: const TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getThaiCurrentDate(),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'อรุณสวัสดิ์ คุณ${profile.name}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => NotificationsSheet.show(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEAE5DB)),
                      ),
                      alignment: Alignment.center,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Text('🔔', style: TextStyle(fontSize: 20)),
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD92D20),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 3 Status Summary Cards (Expired, Expiring Soon, Total)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onNavigateTab?.call(1),
                      child: _buildSummaryCard(
                        iconEmoji: '❌',
                        count: state.expiredItemsCount,
                        label: 'หมดแล้ว',
                        bgColor: const Color(0xFFFDE8E8),
                        countColor: const Color(0xFFD92D20),
                        iconBgColor: const Color(0xFFF97066),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onNavigateTab?.call(1),
                      child: _buildSummaryCard(
                        iconEmoji: '!',
                        count: state.expiringSoonItemsCount,
                        label: 'ใกล้หมด',
                        bgColor: const Color(0xFFFEF3C7),
                        countColor: const Color(0xFFD97706),
                        iconBgColor: const Color(0xFFFBBF24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onNavigateTab?.call(1),
                      child: _buildSummaryCard(
                        iconEmoji: '🧺',
                        count: state.totalItemsCount,
                        label: 'ทั้งหมด',
                        bgColor: Colors.white,
                        countColor: AppColors.textDark,
                        iconBgColor: const Color(0xFFF8F5EE),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Meds Progress Bar & Next Medicine Action Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Bar Row
                    Row(
                      children: [
                        const Text('💊', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: state.todayTotalMedsCount == 0 ? 0.0 : state.todayMedProgressRatio,
                              minHeight: 10,
                              backgroundColor: const Color(0xFFE5E0D6),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${state.todayCompletedMedsCount}/${state.todayTotalMedsCount}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (scheduledSlots.isNotEmpty) ...[
                      // Next Scheduled Slot Card
                      Builder(builder: (context) {
                        final nextSlot = scheduledSlots.firstWhere(
                          (s) => !s.isTaken,
                          orElse: () => scheduledSlots.first,
                        );
                        final isTaken = nextSlot.isTaken;

                        return Row(
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🌅', style: TextStyle(fontSize: 18)),
                                  const SizedBox(height: 2),
                                  Text(
                                    nextSlot.time,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nextSlot.medicine.name,
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${nextSlot.medicine.doseAmount} ${nextSlot.medicine.doseUnit} ${nextSlot.medicine.timing.iconStr}',
                                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                state.toggleMedTaken(nextSlot.medicine.id, nextSlot.time);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isTaken ? const Color(0xFF1F5C40) : AppColors.success,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_box_rounded, color: Colors.white, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    isTaken ? 'กินแล้ว' : 'กินแล้ว',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ] else ...[
                      // Empty Medicine Reminder state (Matching Screenshot 8)
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1EDE4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add, color: AppColors.textMuted, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'ยังไม่ได้ตั้งเตือนยา',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMedicineScreen()));
                            },
                            icon: const Text('💊', style: TextStyle(fontSize: 16)),
                            label: const Text('เพิ่มยา', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE5E0D6)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Section: ⏳ ต้องจัดการก่อน
              if (urgentItems.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('⏳', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 8),
                          Text(
                            'ต้องจัดการก่อน',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...urgentItems.take(4).map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F5EE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(item.emojiIcon, style: const TextStyle(fontSize: 22)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.sourceTag ?? '${item.location} • ${item.quantity} ${item.unit}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showItemActionDialog(context, item),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: item.isExpired ? AppColors.primary : const Color(0xFFD97706),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: item.isExpired
                                      ? const Icon(Icons.close, color: Colors.white, size: 16)
                                      : Text(
                                          item.statusBadgeText,
                                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Section: ⚠️ 💊 ยาใกล้หมด
              if (lowStockMeds.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('⚠️', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 4),
                          Text('💊', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 6),
                          Text(
                            'ยาใกล้หมด',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...lowStockMeds.map((m) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(m.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            Text(
                              '${m.totalPillsRemaining} ${m.doseUnit}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Section: 📅 กินยา 7 วัน (Streak / Adherence Tracker)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text('📅', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 6),
                            Text(
                              'กินยา 7 วัน',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                          ],
                        ),
                        Text(
                          state.todayTotalMedsCount == 0 ? '-' : '${state.streakPercentage}%',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.success),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: state.sevenDayHistory.map((day) {
                        final isDone = day['status'] == 'done';
                        final isPartial = day['status'] == 'partial';
                        final isCurrent = day['isCurrent'] == true;

                        return Column(
                          children: [
                            if (isDone)
                              Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, size: 16, color: Colors.white),
                              )
                            else if (isPartial)
                              Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFBBF24),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Text('!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              )
                            else
                              Container(
                                width: 14,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1EDE4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isCurrent ? AppColors.textDark : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                day['day'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent ? Colors.white : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Section: ♻️ 30 วันที่ผ่านมา Tip Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('♻️', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '30 วันที่ผ่านมา',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '👉 แตะของในบ้าน แล้วเลือก ✅ ใช้หมด หรือ 🗑️ ทิ้ง',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Quick Action Bar (Matching screenshot bottom bar: [📷 สแกน] [🧺 ของ] [💊 ยา])
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()));
                        },
                        icon: const Text('📷', style: TextStyle(fontSize: 18)),
                        label: const Text('สแกน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkButton,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemScreen()));
                        },
                        icon: const Text('🧺', style: TextStyle(fontSize: 18)),
                        label: const Text('ของ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMedicineScreen()));
                        },
                        icon: const Text('💊', style: TextStyle(fontSize: 18)),
                        label: const Text('ยา', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFE5E0D6)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String iconEmoji,
    required int count,
    required String label,
    required Color bgColor,
    required Color countColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              iconEmoji,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: countColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: countColor.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
