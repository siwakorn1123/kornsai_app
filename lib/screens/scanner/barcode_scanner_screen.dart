import 'package:flutter/material.dart';
import '../../models/pantry_item.dart';
import '../../theme/app_colors.dart';
import '../../services/barcode_database.dart';
import '../pantry/add_item_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _hasCameraPermission = true;
  bool _isFlashOn = false;

  void _onProductDetected(ScannedProduct product) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AddItemScreen(scannedProduct: product),
      ),
    );
  }

  void _showManualBarcodeInput() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'พิมพ์หรือเลือกรหัสบาร์โค้ด',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'เช่น 8851122334455 (ข้าวกล่อง 7-11)',
                filled: true,
                fillColor: const Color(0xFFF8F5EE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: AppColors.primary),
                  onPressed: () {
                    final code = controller.text.trim();
                    if (code.isNotEmpty) {
                      Navigator.pop(ctx);
                      final product = BarcodeDatabase.lookup(code) ??
                          ScannedProduct(
                            barcode: code,
                            name: 'สินค้าบาร์โค้ด $code',
                            category: ItemCategory.food,
                            emojiIcon: '📦',
                            defaultExpiryDays: 7,
                          );
                      _onProductDetected(product);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('รายการตัวอย่างยอดนิยม (ตาม Pitch Deck):', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BarcodeDatabase.presetProducts.map((p) {
                final is2D = p.name.contains('7-11');
                return ActionChip(
                  avatar: Text(p.emojiIcon),
                  label: Text(
                    is2D ? '${p.name} (บาร์โค้ด 2D)' : p.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: is2D ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                  backgroundColor: is2D ? const Color(0xFFFFECC4) : const Color(0xFFF1EDE4),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _onProductDetected(p);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCameraPermission) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('สแกนบาร์โค้ด / QR'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Text('📷', style: TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 16),
              const Text(
                'ต้องใช้กล้องเพื่อสแกน',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => setState(() => _hasCameraPermission = true),
                icon: const Icon(Icons.check_box_rounded, color: Colors.white),
                label: const Text('อนุญาตกล้อง'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'สแกนบาร์โค้ด / QR',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: _isFlashOn ? Colors.amber : Colors.white,
            ),
            onPressed: () => setState(() => _isFlashOn = !_isFlashOn),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Simulated Camera Viewfinder with active scanning line
          Positioned.fill(
            child: Container(
              color: const Color(0xFF111418),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 2D Barcode feature badge (Pitch deck page 7)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFECC4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🍱', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'รองรับบาร์โค้ด 2D สินค้า 7-11 (อ่านวันหมดอายุฝังในบาร์โค้ด 100%)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Target Frame
                    Container(
                      width: 280,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 3),
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                          // Animated scanning line
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: -80, end: 80),
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, value),
                                child: Container(
                                  width: 250,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.8),
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'เล็งบาร์โค้ด 1D / 2D หรือ QR ให้อยู่ในกรอบ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom quick barcode picker controls & Demo presets
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick test items chips
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚡ กดเพื่อจำลองการสแกน (Demo Test):',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // 7-11 2D Barcode demo
                            GestureDetector(
                              onTap: () {
                                final p = BarcodeDatabase.presetProducts.firstWhere((item) => item.name.contains('7-11'));
                                _onProductDetected(p);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Text('🍱', style: TextStyle(fontSize: 14)),
                                    SizedBox(width: 6),
                                    Text(
                                      'ข้าวกล่อง 7-11 (2D Barcode)',
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Milk
                            GestureDetector(
                              onTap: () {
                                final p = BarcodeDatabase.presetProducts.firstWhere((item) => item.name.contains('นม'));
                                _onProductDetected(p);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Text('🥛', style: TextStyle(fontSize: 14)),
                                    SizedBox(width: 6),
                                    Text(
                                      'นมสดพาสเจอร์ไรส์',
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Paracetamol
                            GestureDetector(
                              onTap: () {
                                final p = BarcodeDatabase.presetProducts.firstWhere((item) => item.name.contains('พารา'));
                                _onProductDetected(p);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Text('💊', style: TextStyle(fontSize: 14)),
                                    SizedBox(width: 6),
                                    Text(
                                      'พาราเซตามอล ซาร่า',
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Manual Input Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showManualBarcodeInput,
                    icon: const Icon(Icons.keyboard, color: Colors.white),
                    label: const Text('พิมพ์รหัสบาร์โค้ดเอง', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
