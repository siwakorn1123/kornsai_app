import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pantry_item.dart';
import '../../providers/app_state.dart';
import '../../services/barcode_database.dart';
import '../../theme/app_colors.dart';
import '../meds/add_medicine_screen.dart';
import '../scanner/barcode_scanner_screen.dart';

class AddItemScreen extends StatefulWidget {
  final ScannedProduct? scannedProduct;
  final int initialTabIndex; // 0: ของหมดอายุ, 1: ยาที่กินประจำ

  const AddItemScreen({
    super.key,
    this.scannedProduct,
    this.initialTabIndex = 0,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  int _currentTab = 0; // 0: ของหมดอายุ, 1: ยาที่กินประจำ
  late ItemCategory _selectedCategory;
  late TextEditingController _nameController;
  late String _selectedEmoji;
  DateTime? _selectedExpiryDate;
  int? _selectedPresetDays;
  String _selectedLocation = 'ตู้เย็น';
  bool _isConfirmedByAi = false;
  String? _sourceTag;

  final List<String> _emojiOptions = [
    '🍎', '🥛', '🍱', '🥚', '🍞', '🍦', '🧀', '🍗', '💊', '📄', '📦', '🧃', '🥫', '🍫', '🥩', '🥗'
  ];

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTabIndex;

    if (widget.scannedProduct != null) {
      final p = widget.scannedProduct!;
      _selectedCategory = p.category;
      _nameController = TextEditingController(text: p.name);
      _selectedEmoji = p.emojiIcon;
      _selectedPresetDays = p.defaultExpiryDays;
      _selectedExpiryDate = DateTime.now().add(Duration(days: p.defaultExpiryDays));
      _selectedLocation = p.location;
      _sourceTag = p.barcode.startsWith('88511') ? 'อ่านวันจากบาร์โค้ด 2D' : 'สแกนบาร์โค้ด';
      _isConfirmedByAi = true;
    } else {
      _selectedCategory = ItemCategory.food;
      _nameController = TextEditingController(text: 'นมสดพาสเจอร์ไรส์ 1 ล.');
      _selectedEmoji = '🥛';
      _selectedPresetDays = 7;
      _selectedExpiryDate = DateTime.now().add(const Duration(days: 7));
      _isConfirmedByAi = false;
      _sourceTag = 'AI แนะนำ';
    }

    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final text = _nameController.text.trim().toLowerCase();
    if (text.isEmpty) return;

    // Rule-based smart auto-suggestions based on keyword (Pitch deck demo)
    int days = 7;
    String emoji = '🍎';
    ItemCategory cat = ItemCategory.food;

    if (text.contains('นม')) {
      days = 7;
      emoji = '🥛';
    } else if (text.contains('ข้าว') || text.contains('กล่อง') || text.contains('7-11')) {
      days = 2;
      emoji = '🍱';
    } else if (text.contains('ขนมปัง') || text.contains('ปัง')) {
      days = 4;
      emoji = '🍞';
    } else if (text.contains('ไข่')) {
      days = 14;
      emoji = '🥚';
    } else if (text.contains('โยเกิร์ต')) {
      days = 10;
      emoji = '🍦';
    } else if (text.contains('ยา') || text.contains('พารา') || text.contains('วิตามิน')) {
      days = 365;
      emoji = '💊';
      cat = ItemCategory.medicine;
    } else if (text.contains('ประกัน') || text.contains('สัญญา') || text.contains('เอกสาร')) {
      days = 45;
      emoji = '📄';
      cat = ItemCategory.document;
    }

    if (!_isConfirmedByAi) {
      setState(() {
        _selectedEmoji = emoji;
        _selectedCategory = cat;
        _selectedPresetDays = days;
        _selectedExpiryDate = DateTime.now().add(Duration(days: days));
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _selectPresetDays(int days) {
    setState(() {
      _selectedPresetDays = days;
      _selectedExpiryDate = DateTime.now().add(Duration(days: days));
      _isConfirmedByAi = true;
      _sourceTag = 'ผู้ใช้เลือก';
    });
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? now.add(const Duration(days: 7)),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
        _selectedPresetDays = null;
        _isConfirmedByAi = true;
        _sourceTag = 'ผู้ใช้กำหนดเอง';
      });
    }
  }

  String _formatThaiDate(DateTime date) {
    final thaiMonths = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    final year = date.year + 543;
    return '${date.day} ${thaiMonths[date.month - 1]} $year';
  }

  void _confirmAiDate() {
    setState(() {
      _isConfirmedByAi = true;
      _sourceTag = 'ยืนยันวันที่แล้ว';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ ยืนยันวันหมดอายุเรียบร้อยแล้ว'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _saveItem() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกชื่อสินค้า'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกวันหมดอายุ'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final newItem = PantryItem(
      id: 'item_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      emojiIcon: _selectedEmoji,
      category: _selectedCategory,
      expiryDate: _selectedExpiryDate!,
      location: _selectedLocation,
      barcode: widget.scannedProduct?.barcode,
      sourceTag: _sourceTag ?? (_isConfirmedByAi ? 'ยืนยันวันที่แล้ว' : 'บันทึกด่วน'),
    );

    Provider.of<AppState>(context, listen: false).addPantryItem(newItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 บันทึก "$name" เรียบร้อยแล้ว'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context);
  }

  void _openScanner() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('เลือกไอคอน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _emojiOptions.map((e) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedEmoji = e);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F5EE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(e, style: const TextStyle(fontSize: 26)),
                  ),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('เพิ่มของ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Two Tabs (Matching Page 4 & 5)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEBE2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _currentTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _currentTab == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _currentTab == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 4,
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'ของหมดอายุ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: _currentTab == 0 ? FontWeight.bold : FontWeight.w500,
                              color: _currentTab == 0 ? AppColors.textDark : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Open Add Medicine screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _currentTab == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'ยาที่กินประจำ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: _currentTab == 1 ? FontWeight.bold : FontWeight.w500,
                              color: _currentTab == 1 ? AppColors.textDark : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Product Name Input with inline "สแกน" button (Matching Page 5)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E0D6)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _showEmojiPicker,
                      child: Text(_selectedEmoji, style: const TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'พิมพ์ชื่อ เช่น นมสดพาสเจอร์ไรส์ 1 ล.',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: AppColors.textSubtle, fontSize: 15),
                        ),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _openScanner,
                      icon: const Icon(Icons.qr_code_scanner, size: 18, color: AppColors.primary),
                      label: const Text(
                        'สแกน',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF1EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Suggestion Box: "AI แนะนำ · แก้ไขได้" (Matching Page 4 & 5)
              if (_selectedExpiryDate != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E0D6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('✨', style: TextStyle(fontSize: 13)),
                                SizedBox(width: 4),
                                Text(
                                  'AI แนะนำ · แก้ไขได้',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (_isConfirmedByAi)
                            const Row(
                              children: [
                                Icon(Icons.check_circle, size: 16, color: AppColors.success),
                                SizedBox(width: 4),
                                Text('ยืนยันแล้ว', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold)),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Builder(builder: (context) {
                        final days = _selectedExpiryDate!.difference(DateTime.now()).inDays + 1;
                        final formattedDate = _formatThaiDate(_selectedExpiryDate!);
                        final textDays = days <= 0 ? 'หมดวันนี้' : 'อีก $days วัน';

                        return Text(
                          '$formattedDate · $textDays',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _pickCustomDate,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE5E0D6)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'แก้ไขวันที่',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _confirmAiDate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isConfirmedByAi ? const Color(0xFF1F5C40) : AppColors.success,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                _isConfirmedByAi ? '✓ ยืนยันแล้ว' : 'ยืนยัน',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Quick Day Buttons: [ 3 วัน ] [ 7 วัน ] [ 1 ด. ] [ 1 ปี ] (Matching Page 5)
              Row(
                children: [
                  _buildQuickPill('3 วัน', 3),
                  const SizedBox(width: 8),
                  _buildQuickPill('7 วัน', 7),
                  const SizedBox(width: 8),
                  _buildQuickPill('1 ด.', 30),
                  const SizedBox(width: 8),
                  _buildQuickPill('1 ปี', 365),
                ],
              ),
              const SizedBox(height: 24),

              // Category & Location Selection Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E0D6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📁 หมวดหมู่และที่เก็บ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ItemCategory.values.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('${cat.emoji} ${cat.label}'),
                              selected: isSelected,
                              selectedColor: const Color(0xFFFFECC4),
                              backgroundColor: const Color(0xFFF8F5EE),
                              onSelected: (_) => setState(() => _selectedCategory = cat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('📍 เก็บที่: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                        const SizedBox(width: 8),
                        Wrap(
                          spacing: 6,
                          children: ['ตู้เย็น', 'โต๊ะอาหาร', 'ตู้ยา', 'ชั้นวาง'].map((loc) {
                            final isSel = _selectedLocation == loc;
                            return ChoiceChip(
                              label: Text(loc, style: TextStyle(fontSize: 13, color: isSel ? AppColors.primary : AppColors.textDark)),
                              selected: isSel,
                              selectedColor: const Color(0xFFFFF1EB),
                              backgroundColor: const Color(0xFFF8F5EE),
                              onSelected: (_) => setState(() => _selectedLocation = loc),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Big Action Button: บันทึกของชิ้นนี้ (Matching Page 5)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 2,
                  ),
                  child: const Text(
                    'บันทึกของชิ้นนี้',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Pitch deck footnote (Page 4 & 5)
              const Center(
                child: Text(
                  '💡 วันที่ทุกครั้งเป็นคำแนะนำที่ผู้ใช้ยืนยันเอง ระบบไม่บันทึกให้เองโดยไม่ถาม',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPill(String label, int days) {
    final isSelected = _selectedPresetDays == days;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectPresetDays(days),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.textDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? AppColors.textDark : const Color(0xFFE5E0D6)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
