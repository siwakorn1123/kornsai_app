import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../onboarding/onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showSubscriptionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
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
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1EB),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Text('👑', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subscription ดูแลพ่อแม่จากระยะไกล',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      Text(
                        'คนไม่จ่ายเพื่อช่วยจำ แต่จ่ายเพื่อความอุ่นใจ',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5EE),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _buildSubFeature('🔔', 'แจ้งเตือนลูกหลานทันที หากพ่อแม่ไม่ได้กดยืนยันมื้อยา'),
                  const SizedBox(height: 10),
                  _buildSubFeature('📊', 'สรุปรายงานการกินยาประจำสัปดาห์ ส่งตรงเข้า LINE'),
                  const SizedBox(height: 10),
                  _buildSubFeature('🍱', 'อ่านวันหมดอายุจากบาร์โค้ด 2D อาหาร 7-Eleven ไม่จำกัด'),
                  const SizedBox(height: 10),
                  _buildSubFeature('👨‍👩‍👧‍👦', 'เชื่อมต่อบัญชีดูแลคนในครอบครัวสูงสุด 5 คน'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFECC4)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('แพ็กเกจครอบครัวอุ่นใจ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('ทดลองใช้งานฟรี 14 วันแรก', style: TextStyle(fontSize: 12, color: Color(0xFFD97706), fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text('฿99 / เดือน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 เริ่มต้นทดลองใช้สิทธิ์ Family Care 14 วันเรียบร้อยแล้ว'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('เริ่มต้นทดลองใช้ฟรี 14 วัน', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  static Widget _buildSubFeature(String icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ),
      ],
    );
  }

  void _showTeamModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
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
            const Text(
              'ทีมงานเบื้องหลัง ก่อนสาย',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            const Text(
              'ทีมนักพัฒนาและผู้ออกแบบตามเอกสารนำเสนอ',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            _buildTeamMemberCard('อนุชา นามลี', '65162110344-3', 'พัฒนาแอปพลิเคชัน', '💻'),
            _buildTeamMemberCard('ศิวกร พลคำแก้ว', '65162110355-0', 'ออกแบบ UX และ UI', '🎨'),
            _buildTeamMemberCard('สุริยา เร็ววันทึก', '66182110149-9', 'แผนธุรกิจและการตลาด', '📈'),
            _buildTeamMemberCard('ศักดิภัทร กาญจนพิมาย', '65182110045-2', 'วิจัยคู่แข่งและข้อมูลตลาด', '🔍'),
            _buildTeamMemberCard('วงศธร ใจเที่ยง', '66172310546-3', 'แผนธุรกิจและการตลาด', '💼'),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard(String name, String id, String role, String emoji) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5EE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                Text('$id • $role', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    final nameController = TextEditingController(text: state.profile.name);
    String avatar = state.profile.avatarEmoji;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('แก้ไขโปรไฟล์', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                children: ['😊', '👩', '👦', '👵', '👴', '👨‍🍳', '👩‍⚕️', '🐱'].map((a) {
                  return GestureDetector(
                    onTap: () => setDialogState(() => avatar = a),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: avatar == a ? const Color(0xFFFFF3EE) : Colors.transparent,
                        border: Border.all(color: avatar == a ? AppColors.primary : Colors.transparent, width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(a, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อ',
                  filled: true,
                  fillColor: const Color(0xFFF8F5EE),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  state.updateProfile(name: name, avatarEmoji: avatar);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('บันทึก'),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'โปรไฟล์ & การตั้งค่า',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            // User Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFECC4), width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(profile.avatarEmoji, style: const TextStyle(fontSize: 36)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'คุณ${profile.name}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'ดูแล: คุณแม่สมศรี (ผูกบัญชีแล้ว)',
                          style: TextStyle(fontSize: 13, color: Color(0xFFD97706), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                    onPressed: () => _showEditProfileDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Subscription Banner (Pitch Deck Page 8)
            GestureDetector(
              onTap: () => _showSubscriptionModal(context),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text('👑', style: TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subscription ดูแลพ่อแม่ทางไกล',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'แจ้งเตือนลูกหลานเมื่อพ่อแม่ลืมกินยา',
                            style: TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Settings Group
            const Text(
              'การตั้งค่าทั่วไป',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text('ABCD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                    title: const Text('ตัวอักษรใหญ่ (สำหรับผู้สูงอายุ)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: const Text('ขยายขนาดตัวอักษรให้อ่านง่าย สบายตา', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    value: profile.isLargeText,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => state.updateProfile(isLargeText: val),
                  ),
                  const Divider(height: 1, indent: 64),
                  SwitchListTile(
                    secondary: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🔔', style: TextStyle(fontSize: 18)),
                    ),
                    title: const Text('การแจ้งเตือนเตือนกินยาและของหมดอายุ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: const Text('เตือนล่วงหน้า 3 วัน และเตือนตามมื้อยาทุกวัน', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    value: profile.notificationsEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) => state.updateProfile(notificationsEnabled: val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Data Management Group & Pitch Deck Info
            const Text(
              'ข้อมูลและทีมงาน',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text('📥', style: TextStyle(fontSize: 18)),
                    ),
                    title: const Text('โหลดข้อมูลตัวอย่าง Pitch Deck', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: const Text('รีเซ็ตข้อมูลให้ตรงกับตัวอย่างในสไลด์นำเสนอ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    onTap: () async {
                      await state.resetToSampleData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('โหลดข้อมูลตัวอย่าง Pitch Deck เรียบร้อยแล้ว'), backgroundColor: AppColors.success),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 64),
                  ListTile(
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3EE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text('👥', style: TextStyle(fontSize: 18)),
                    ),
                    title: const Text('ทีมงานเบื้องหลัง ก่อนสาย', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: const Text('ดูรายชื่อผู้พัฒนาและออกแบบโครงการ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    onTap: () => _showTeamModal(context),
                  ),
                  const Divider(height: 1, indent: 64),
                  ListTile(
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text('🗑️', style: TextStyle(fontSize: 18)),
                    ),
                    title: const Text('ล้างข้อมูลทั้งหมด', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.danger)),
                    subtitle: const Text('ลบรายการของ ยา และสถิติทั้งหมด', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text('ยืนยันล้างข้อมูล', style: TextStyle(fontWeight: FontWeight.bold)),
                          content: const Text('คุณต้องการลบข้อมูลทั้งหมดในแอพและเริ่มต้นใหม่ใช่หรือไม่?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                state.clearAllData();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                              child: const Text('ล้างข้อมูล'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Footer
            Center(
              child: Column(
                children: const [
                  Text('ก่อนสาย (Kornsai)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                  SizedBox(height: 2),
                  Text('รู้ก่อนของหมดอายุ ไม่ลืมกินยา', style: TextStyle(fontSize: 12, color: AppColors.textSubtle)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
