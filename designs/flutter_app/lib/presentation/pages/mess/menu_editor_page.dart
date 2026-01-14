import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';

class MenuEditorPage extends StatefulWidget {
  final Map<String, List<String>>? initialMenu;
  final Map<String, String>? initialTimes;

  const MenuEditorPage({super.key, this.initialMenu, this.initialTimes});

  @override
  State<MenuEditorPage> createState() => _MenuEditorPageState();
}

class _MenuEditorPageState extends State<MenuEditorPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  
  // Controllers
  late TextEditingController _breakfastCtrl;
  late TextEditingController _lunchCtrl;
  late TextEditingController _snacksCtrl;
  late TextEditingController _dinnerCtrl;
  
  late TextEditingController _breakTimeCtrl;
  late TextEditingController _lunchTimeCtrl;
  late TextEditingController _snackTimeCtrl;
  late TextEditingController _dinnerTimeCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this, initialIndex: 1);
    
    // Init with passed data or defaults
    final m = widget.initialMenu ?? {};
    final t = widget.initialTimes ?? {};
    
    _breakfastCtrl = TextEditingController(text: (m["Breakfast"] ?? []).join(", "));
    _lunchCtrl = TextEditingController(text: (m["Lunch"] ?? []).join(", "));
    _snacksCtrl = TextEditingController(text: (m["Snacks"] ?? []).join(", "));
    _dinnerCtrl = TextEditingController(text: (m["Dinner"] ?? []).join(", "));
    
    _breakTimeCtrl = TextEditingController(text: t["Breakfast"] ?? "07:30 - 09:30");
    _lunchTimeCtrl = TextEditingController(text: t["Lunch"] ?? "12:30 - 14:30");
    _snackTimeCtrl = TextEditingController(text: t["Snacks"] ?? "16:30 - 17:30");
    _dinnerTimeCtrl = TextEditingController(text: t["Dinner"] ?? "19:30 - 21:30");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Edit Menu", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
               // Create Maps
               final newMenu = {
                 "Breakfast": _breakfastCtrl.text.split(',').map((e) => e.trim()).toList(),
                 "Lunch": _lunchCtrl.text.split(',').map((e) => e.trim()).toList(),
                 "Snacks": _snacksCtrl.text.split(',').map((e) => e.trim()).toList(),
                 "Dinner": _dinnerCtrl.text.split(',').map((e) => e.trim()).toList(),
               };
               
               final newTimes = {
                 "Breakfast": _breakTimeCtrl.text,
                 "Lunch": _lunchTimeCtrl.text,
                 "Snacks": _snackTimeCtrl.text,
                 "Dinner": _dinnerTimeCtrl.text,
               };
               
               context.pop({'menu': newMenu, 'times': newTimes});
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menu Updates Saved Locally!")));
            },
            child: Text("Save", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.primary)),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          indicatorColor: Colors.black,
          tabs: _days.map((d) => Tab(text: d)).toList(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildEditorField("Breakfast", _breakfastCtrl, _breakTimeCtrl, AppColors.pastelOrange),
            const SizedBox(height: 24),
            _buildEditorField("Lunch", _lunchCtrl, _lunchTimeCtrl, AppColors.pastelGreen),
            const SizedBox(height: 24),
            _buildEditorField("Snacks", _snacksCtrl, _snackTimeCtrl, AppColors.pastelBlue),
            const SizedBox(height: 24),
            _buildEditorField("Dinner", _dinnerCtrl, _dinnerTimeCtrl, AppColors.pastelPurple),
            
            const SizedBox(height: 40),
            
            // OCR Helper
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Ionicons.camera, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Auto-Scan Menu", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Take a photo of the mess whiteboard to auto-fill.", style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Icon(Ionicons.chevron_forward, color: Colors.grey),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEditorField(String label, TextEditingController itemCtrl, TextEditingController timeCtrl, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                 const SizedBox(width: 8),
                Text(label, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            // Time Input (Small)
            SizedBox(
              width: 120,
              height: 36,
              child: TextField(
                controller: timeCtrl,
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  hintText: "Time",
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: itemCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: color.withOpacity(0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            hintText: "Enter items separated by comma...",
          ),
          style: GoogleFonts.dmSans(fontSize: 16),
        ),
      ],
    );
  }
}
