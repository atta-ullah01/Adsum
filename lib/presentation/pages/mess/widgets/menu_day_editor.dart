import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class MenuDayEditor extends StatefulWidget {

  const MenuDayEditor({
    required this.menus, required this.onSave, required this.hostelId, required this.day, super.key,
  });
  final List<MessMenu> menus;
  final Function(List<MessMenu>) onSave;
  final String hostelId;
  final MessDayOfWeek day;

  @override
  State<MenuDayEditor> createState() => _MenuDayEditorState();
}

class _MenuDayEditorState extends State<MenuDayEditor> {
  final Map<MealType, TextEditingController> _itemCtrls = {};
  final Map<MealType, TextEditingController> _timeCtrls = {};

  @override
  void initState() {
    super.initState();
    for (final type in MealType.values) {
      // Find menu for this type
      final menu = widget.menus.firstWhere(
        (m) => m.mealType == type, 
        orElse: () => MessMenu(
            menuId: '${widget.hostelId}_${widget.day.name}_${type.name}',
            hostelId: widget.hostelId,
            dayOfWeek: widget.day,
            mealType: type,
            startTime: _defaultTime(type),
            endTime: _defaultEndTime(type),
            items: ''
        )
      );
      
      _itemCtrls[type] = TextEditingController(text: menu.items);
      _timeCtrls[type] = TextEditingController(text: '${menu.startTime} - ${menu.endTime}');
    }
  }

  String _defaultTime(MealType type) {
    switch (type) {
      case MealType.breakfast: return '07:30';
      case MealType.lunch: return '12:30';
      case MealType.snacks: return '16:30';
      case MealType.dinner: return '19:30';
    }
  }
  
  String _defaultEndTime(MealType type) {
    switch (type) {
      case MealType.breakfast: return '09:30';
      case MealType.lunch: return '14:30';
      case MealType.snacks: return '17:30';
      case MealType.dinner: return '21:30';
    }
  }

  @override
  void dispose() {
    for (final c in _itemCtrls.values) {
      c.dispose();
    }
    for (final c in _timeCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final updates = <MessMenu>[];
    for (final type in MealType.values) {
       // Reconstruct
       final items = _itemCtrls[type]!.text;
       final timeStr = _timeCtrls[type]!.text;
       final parts = timeStr.split('-').map((e) => e.trim()).toList();
       final start = parts.isNotEmpty ? parts[0] : _defaultTime(type);
       final end = parts.length > 1 ? parts[1] : _defaultEndTime(type);
       
       // Find original ID to preserve it (or create new based on pattern)
       final original = widget.menus.firstWhere(
        (m) => m.mealType == type,
        orElse: () => MessMenu(
            menuId: '${widget.hostelId}_${widget.day.name}_${type.name}',
            hostelId: widget.hostelId,
            dayOfWeek: widget.day,
            mealType: type,
            startTime: start,
            endTime: end,
            items: ''
        )
       );
       
       updates.add(original.copyWith(
         items: items,
         startTime: start,
         endTime: end,
         isModified: true
       ));
    }
    widget.onSave(updates);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildEditorField('Breakfast', _itemCtrls[MealType.breakfast]!, _timeCtrls[MealType.breakfast]!, AppColors.pastelOrange),
        const SizedBox(height: 24),
        _buildEditorField('Lunch', _itemCtrls[MealType.lunch]!, _timeCtrls[MealType.lunch]!, AppColors.pastelGreen),
        const SizedBox(height: 24),
        _buildEditorField('Snacks', _itemCtrls[MealType.snacks]!, _timeCtrls[MealType.snacks]!, AppColors.pastelBlue),
        const SizedBox(height: 24),
        _buildEditorField('Dinner', _itemCtrls[MealType.dinner]!, _timeCtrls[MealType.dinner]!, AppColors.pastelPurple),
        
        const SizedBox(height: 40),
        
        // Save Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Save Changes', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
        
        const SizedBox(height: 24),

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
                    Text('Auto-Scan Menu', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Take a photo of the mess whiteboard to auto-fill.', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Ionicons.chevron_forward, color: Colors.grey),
            ],
          ),
        )
      ],
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  fillColor: Colors.grey[100],
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  hintText: 'Time',
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
            hintText: 'Enter items separated by comma...',
          ),
          style: GoogleFonts.dmSans(fontSize: 16),
        ),
      ],
    );
  }
}
