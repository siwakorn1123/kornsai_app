import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicine_item.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stockController = TextEditingController(text: '30');
  final TextEditingController _thresholdController = TextEditingController(text: '5');

  String _selectedOwner = 'Ee';
  final String _selectedEmoji = '💊';
  int _doseAmount = 1;
  String _selectedUnit = 'เม็ด';
  MedicineTiming _timing = MedicineTiming.afterMeal;
  final Set<String> _selectedTimes = {'08:00'};

  final List<String> _unitOptions = ['เม็ด', 'แคปซูล', 'ช้อนชา', 'หยด', 'ซอง'];
  final List<Map<String, String>> _timePresets = [
    {'time': '08:00', 'label': 'เช้า 08:00', 'icon': '🌅'},
    {'time': '12:30', 'label': 'กลางวัน 12:30', 'icon': '☀️'},
    {'time': '18:00', 'label': 'เย็น 18:00', 'icon': '🌆'},
    {'time': '21:00', 'label': 'ก่อนนอน 21:00', 'icon': '🌙'},
  ];

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<AppState>(context, listen: false).profile;
    _selectedOwner = profile.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  void _addCustomTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
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
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minStr = picked.minute.toString().padLeft(2, '0');
      setState(() {
        _selectedTimes.add('$hourStr:$minStr');
      });
    }
  }

  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    String avatar = '👩';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('เพิ่มคนในบ้าน', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['👩', '👦', '👵', '👴', '🐱'].map((a) {
                  return GestureDetector(
                    onTap: () => setDialogState(() => avatar = a),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: avatar == a ? AppColors.primaryLight : Colors.transparent,
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
                  hintText: 'ชื่อ (เช่น คุณพ่อ)',
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
                  Provider.of<AppState>(context, listen: false).addMember(name, avatar);
                  setState(() => _selectedOwner = name);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('เพิ่ม'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveMedicine() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกชื่อยา'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกเวลากินยาอย่างน้อย 1 เวลา'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final stock = int.tryParse(_stockController.text.trim()) ?? 30;
    final threshold = int.tryParse(_thresholdController.text.trim()) ?? 5;

    final newMed = MedicineItem(
      id: 'med_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      emojiIcon: _selectedEmoji,
      ownerName: _selectedOwner,
      doseAmount: _doseAmount,
      doseUnit: _selectedUnit,
      timing: _timing,
      scheduleTimes: _selectedTimes.toList()..sort(),
      totalPillsRemaining: stock,
      alertThreshold: threshold,
    );

    Provider.of<AppState>(context, listen: false).addMedicine(newMed);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('บันทึกและเริ่มเตือน "$name" เรียบร้อยแล้ว'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final members = Provider.of<AppState>(context).profile.members;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('เพิ่มยา'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Owner Selection Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E0D6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('👥 ยาของใคร', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...members.map((m) {
                          final isSelected = _selectedOwner == m.name;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedOwner = m.name),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.textDark : const Color(0xFFF8F5EE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSelected) ...[
                                    const Icon(Icons.check, size: 16, color: Colors.white),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    '${m.avatarEmoji} ${m.name}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        GestureDetector(
                          onTap: _showAddMemberDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE5E0D6)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 16, color: AppColors.textDark),
                                SizedBox(width: 4),
                                Text('เพิ่มคน', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Medicine Name Field
              const Text('💊 ชื่อยา', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFECC4)),
                    ),
                    alignment: Alignment.center,
                    child: const Text('😊', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E0D6)),
                      ),
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'เช่น ยาความดัน',
                          hintStyle: TextStyle(color: AppColors.textSubtle),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Dosage Amount & Unit
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E0D6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔢 กินครั้งละ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        // Counter - 1 +
                        GestureDetector(
                          onTap: () {
                            if (_doseAmount > 1) setState(() => _doseAmount--);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1EDE4),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.remove, color: AppColors.textDark),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '$_doseAmount',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => setState(() => _doseAmount++),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AppColors.textDark,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3EE),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Text('💊', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(_selectedUnit, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Unit selector pills
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _unitOptions.map((unit) {
                        final isSelected = _selectedUnit == unit;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedUnit = unit),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.textDark : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? AppColors.textDark : const Color(0xFFE5E0D6)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  const Icon(Icons.check, size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  unit,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Schedule Times
              const Text('⏰ เวลากิน (เตือนทุกวัน)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._timePresets.map((preset) {
                    final isSelected = _selectedTimes.contains(preset['time']);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            if (_selectedTimes.length > 1) _selectedTimes.remove(preset['time']);
                          } else {
                            _selectedTimes.add(preset['time']!);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.textDark : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppColors.textDark : const Color(0xFFE5E0D6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(preset['icon']!, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              preset['label']!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: _addCustomTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E0D6)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16, color: AppColors.textDark),
                          SizedBox(width: 4),
                          Text('เวลาอื่น', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Meal Timing
              const Text('🍽️ กินตอนไหน', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _timing = MedicineTiming.beforeMeal),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _timing == MedicineTiming.beforeMeal ? AppColors.textDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _timing == MedicineTiming.beforeMeal ? AppColors.textDark : const Color(0xFFE5E0D6),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '💊➔🍽️ ก่อนอาหาร',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _timing == MedicineTiming.beforeMeal ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _timing = MedicineTiming.afterMeal),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _timing == MedicineTiming.afterMeal ? AppColors.textDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _timing == MedicineTiming.afterMeal ? AppColors.textDark : const Color(0xFFE5E0D6),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '🍽️➔💊 หลังอาหาร',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _timing == MedicineTiming.afterMeal ? Colors.white : AppColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Stock & Warning
              const Text('📦 เหลืออยู่กี่เม็ด (เว้นว่างได้)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E0D6)),
                ),
                child: TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'เช่น 30',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 14),
              const Text('⚠️ เตือนรับยาเพิ่มเมื่อเหลือ (เม็ด)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E0D6)),
                ),
                child: TextField(
                  controller: _thresholdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '5',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE58871),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🔔', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 8),
                      Text('บันทึกและเริ่มเตือน', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
