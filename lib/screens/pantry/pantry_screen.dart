import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pantry_item.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../home/notifications_sheet.dart';
import '../scanner/barcode_scanner_screen.dart';
import 'add_item_screen.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  String _selectedCategoryFilter = 'ทั้งหมด';
  final String _searchQuery = '';

  String _formatThaiDate(DateTime date) {
    final thaiMonths = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    final year = date.year + 543;
    return '${date.day} ${thaiMonths[date.month - 1]} $year';
  }

  void _showItemActionSheet(BuildContext context, PantryItem item) {
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
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F5EE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(item.emojiIcon, style: const TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        'หมดอายุ: ${_formatThaiDate(item.expiryDate)} (${item.statusBadgeText})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: item.statusBadgeColor,
                        ),
                      ),
                      if (item.sourceTag != null)
                        Text(
                          'ที่มา: ${item.sourceTag}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            ListTile(
              leading: const Text('✅', style: TextStyle(fontSize: 22)),
              title: const Text('กินหมด / ใช้หมดแล้ว', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('บันทึกสถิติการใช้งาน', style: TextStyle(fontSize: 12)),
              onTap: () {
                appState.markPantryItemUsed(item.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('บันทึกใช้ "${item.name}" แล้ว'), backgroundColor: AppColors.success),
                );
              },
            ),
            ListTile(
              leading: const Text('🗑️', style: TextStyle(fontSize: 22)),
              title: const Text('ทิ้งแล้ว (หมดอายุ / เสีย)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
              onTap: () {
                appState.markPantryItemDiscarded(item.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ย้าย "${item.name}" ไปรายการทิ้ง'), backgroundColor: AppColors.textMuted),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.danger),
              title: const Text('ลบรายการนี้', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.danger)),
              onTap: () {
                appState.removePantryItem(item.id);
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
    List<PantryItem> items = state.pantryItems;

    // Filter by category
    if (_selectedCategoryFilter != 'ทั้งหมด') {
      items = items.where((i) => i.category.label == _selectedCategoryFilter).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      items = items.where((i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Sort: expired first, then expiring soon, then safe
    items.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));

    final totalCount = state.totalItemsCount;
    final urgentCount = state.expiredItemsCount + state.expiringSoonItemsCount;
    final medsCount = state.medicines.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ของในบ้าน',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              '$totalCount ชิ้น · ใกล้หมดอายุ $urgentCount · ยาประจำ $medsCount',
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
            icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
            tooltip: 'สแกนบาร์โค้ด',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarcodeScannerScreen())),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category filter chips
            if (state.pantryItems.isNotEmpty) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip('ทั้งหมด'),
                    _buildFilterChip('อาหาร'),
                    _buildFilterChip('ยา/เวชภัณฑ์'),
                    _buildFilterChip('เอกสาร/ประกัน'),
                    _buildFilterChip('อื่นๆ'),
                  ],
                ),
              ),
            ],

            // Item list or Empty state (Matching Page 5 Dashboard)
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            alignment: Alignment.center,
                            child: const Text('🧺', style: TextStyle(fontSize: 64)),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'ยังไม่มีของ',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'กด 📷 หรือ ➕ ด้านล่างเพื่อเพิ่มของ',
                            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return GestureDetector(
                          onTap: () => _showItemActionSheet(context, item),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F5EE),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(item.emojiIcon, style: const TextStyle(fontSize: 26)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        item.sourceTag ?? '${item.location} · ${item.quantity} ${item.unit}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: item.daysRemaining <= 0
                                        ? const Color(0xFFFDE8E8)
                                        : (item.daysRemaining <= 3 ? const Color(0xFFFEF3C7) : const Color(0xFFE8F5E9)),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    item.daysRemaining <= 0
                                        ? 'วันนี้'
                                        : (item.daysRemaining == 1 ? '1 วัน' : '${item.daysRemaining} วัน'),
                                    style: TextStyle(
                                      color: item.daysRemaining <= 0
                                          ? const Color(0xFFD92D20)
                                          : (item.daysRemaining <= 3 ? const Color(0xFFD97706) : const Color(0xFF2E7D32)),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('เพิ่มของ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategoryFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFFFFECC4),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.textDark : AppColors.textMuted,
        ),
        onSelected: (_) {
          setState(() {
            _selectedCategoryFilter = label;
          });
        },
      ),
    );
  }
}
