import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Step 2 State
  String _selectedAvatar = '😊';
  final TextEditingController _nameController = TextEditingController(text: 'Ee');
  bool _isLargeText = false;

  // Step 3 State
  bool _isNotificationGranted = false;

  final List<String> _avatars = ['😊', '👩', '👦', '👵', '👴', '👨‍🍳', '👩‍⚕️', '🐱'];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPrevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding(bool loadSampleData) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final enteredName = _nameController.text.trim().isEmpty ? 'คุณ' : _nameController.text.trim();

    await appState.updateProfile(
      name: enteredName,
      avatarEmoji: _selectedAvatar,
      isLargeText: _isLargeText,
      notificationsEnabled: _isNotificationGranted,
    );

    await appState.completeOnboarding(loadSampleData: loadSampleData);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  void _showNotificationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textDark, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.crop_square_rounded, size: 28, color: AppColors.textDark),
            ),
            const SizedBox(height: 18),
            const Text(
              'อนุญาตให้ ก่อนสาย ส่งการแจ้งเตือนถึงคุณไหม',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isNotificationGranted = true;
                });
              },
              child: const Text(
                'อนุญาต',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _isNotificationGranted = false;
                });
              },
              child: const Text(
                'ไม่อนุญาต',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildPageIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 28 : 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFFE2DDD3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // STEP 1: Feature Intro
  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Spacer(flex: 1),
          // Hourglass
          Container(
            width: 100,
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Text('⏳', style: TextStyle(fontSize: 54)),
          ),
          const SizedBox(height: 18),
          const Text(
            'ก่อนสาย',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'รู้ก่อนของหมดอายุ · ไม่ลืมกินยา',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(flex: 1),
          _buildFeatureCard('🧺', 'จดของในบ้าน ดูสีรู้เลยว่าอะไรใกล้หมด'),
          const SizedBox(height: 12),
          _buildFeatureCard('📷', 'สแกนบาร์โค้ด หรือพิมพ์ชื่อ ระบบแนะนำวันให้'),
          const SizedBox(height: 12),
          _buildFeatureCard('💊', 'เตือนกินยาทุกวัน กดปุ่มเดียวว่ากินแล้ว'),
          const SizedBox(height: 12),
          _buildFeatureCard('📄', 'เตือนต่อประกัน/เอกสาร ล่วงหน้าหลายสัปดาห์'),
          const Spacer(flex: 2),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _goToNextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text('เริ่มเลย', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFFBF8F2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: Name & Preferences
  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Big selected avatar
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFECC4), width: 3),
            ),
            alignment: Alignment.center,
            child: Text(_selectedAvatar, style: const TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 16),
          const Text(
            'ให้แอปเรียกคุณว่าอะไร',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 24),
          // Avatar selector row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _avatars.map((avatar) {
                final isSelected = _selectedAvatar == avatar;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = avatar),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.textDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? AppColors.textDark : const Color(0xFFE5E0D6),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          const Icon(Icons.check, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                        ],
                        Text(avatar, style: const TextStyle(fontSize: 22)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          // Name input field
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '✏️ ชื่อ (เว้นว่างได้)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E3D8)),
            ),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'เช่น แม่ปุ้ย',
                hintStyle: TextStyle(color: AppColors.textSubtle),
                contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          ),
          const SizedBox(height: 20),
          // Large text switch card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8E3D8)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text('ABCD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ตัวอักษรใหญ่', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('อ่านง่ายขึ้น เปลี่ยนทีหลังได้', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Switch(
                  value: _isLargeText,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => _isLargeText = val);
                    Provider.of<AppState>(context, listen: false).updateProfile(isLargeText: val);
                  },
                ),
              ],
            ),
          ),
          const Spacer(),
          // Back & Next Buttons
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _goToPrevPage,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFE0DBD0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 20),
                        SizedBox(width: 6),
                        Text('กลับ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _goToNextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('ต่อไป', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // STEP 3: Notification Request
  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Big Bell Icon
          Container(
            width: 110,
            height: 110,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: const Text('🔔', style: TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 16),
          const Text(
            'ให้แอปเตือนคุณได้ไหม',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 24),
          // Permission highlight box
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
            child: Column(
              children: [
                _buildBulletItem('⏳', 'ก่อนของหมดอายุ'),
                const SizedBox(height: 18),
                _buildBulletItem('💊', 'ถึงเวลากินยา กด ✅ จากการแจ้งเตือนได้เลย'),
                const SizedBox(height: 18),
                _buildBulletItem('🔒', 'ข้อมูลอยู่ในเครื่องคุณเท่านั้น'),
              ],
            ),
          ),
          if (_isNotificationGranted) ...[
            const SizedBox(height: 28),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_box_rounded, color: AppColors.success, size: 24),
                SizedBox(width: 8),
                Text(
                  'เปิดแจ้งเตือนแล้ว',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
          const Spacer(),
          if (!_isNotificationGranted) ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _showNotificationPermissionDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🔔', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text('อนุญาตแจ้งเตือน', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _goToNextPage,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE0DBD0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('⏭️', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text('ข้ามไปก่อน', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  ],
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _goToNextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('ต่อไป', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  // STEP 4: Choose Initial Data
  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 100,
            height: 100,
            alignment: Alignment.center,
            child: const Text('🎉', style: TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 16),
          const Text(
            'พร้อมแล้ว!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 32),
          // Option 1: Sample Data (Highlighted with orange border)
          GestureDetector(
            onTap: () => _finishOnboarding(true),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3EE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text('📥', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ลองด้วยข้อมูลตัวอย่าง',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'มีของ ยา และกราฟให้ดูทันที ลบทีหลังได้',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Option 2: Start Blank
          GestureDetector(
            onTap: () => _finishOnboarding(false),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.textDark, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text('✨', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เริ่มจากว่างๆ',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'เพิ่มของและยาของคุณเอง',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: AppColors.textDark, size: 24),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
