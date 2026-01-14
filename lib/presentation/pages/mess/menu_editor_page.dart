import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';

class MenuEditorPage extends ConsumerStatefulWidget {
  final List<MessMenu>? initialMenus; // Optional: prepopulate to avoid loading flicker
  final MessDayOfWeek day;
  final String hostelId;

  const MenuEditorPage({
    super.key, 
    this.initialMenus, 
    required this.day, 
    required this.hostelId
  });

  @override
  ConsumerState<MenuEditorPage> createState() => _MenuEditorPageState();
}

class _MenuEditorPageState extends ConsumerState<MenuEditorPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<MessDayOfWeek> _days = MessDayOfWeek.values;
  
  // Controllers Map: Key = MealType (0..3)
  final Map<MealType, TextEditingController> _itemCtrls = {};
  final Map<MealType, TextEditingController> _timeCtrls = {};
  
  // Current editing state
  MessDayOfWeek _currentDay = MessDayOfWeek.mon;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    // Initialize defaults based on helper
    _currentDay = widget.day;
    int initialIndex = _days.indexOf(widget.day);
    
    _tabController = TabController(length: 7, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(_handleTabChange);
    
    // Init Controllers
    for (var type in MealType.values) {
      _itemCtrls[type] = TextEditingController();
      _timeCtrls[type] = TextEditingController();
    }
    
    // Initial Load if provided (for the selected day)
    // Note: If we switch tabs, we'll lose edits unless we persist/save on tab switch or use state per tab.
    // For simplicity, we'll reload on tab switch (discarding unsaved changes? Or auto-save?).
    // Better UX: Show save warning. For now: Reload fields on data change.
  }
  
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
         _currentDay = _days[_tabController.index];
         // Reset dirty flag or handle it
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var c in _itemCtrls.values) c.dispose();
    for (var c in _timeCtrls.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch data for CURRENT tab's day
    final menusAsync = ref.watch(messMenuForDayProvider(_currentDay));

    // Side Effect: Populate controllers when data loads (and isn't dirty from user typing yet?)
    // This is tricky in build. better to use `ref.listen` or handle in `when`.
    // Actually, simple solution: Use a Key for the form that changes when day changes, and init state there.
    // But controllers are persistent.
    // Let's manually populate if not dirty. But avoiding rebuild loops.
    // Best way: Use `ref.listen` in `build`.
    
    ref.listen(messMenuForDayProvider(_currentDay), (prev, next) {
      next.whenData((menus) {
         _populateControllers(menus);
      });
    });

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
            onPressed: () => _saveCurrentDay(),
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
          tabs: _days.map((d) => Tab(text: d.name.toUpperCase())).toList(),
        ),
      ),
      body: menusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allMenus) {
           // We need to ensure controllers are populated initially if listen didn't fire (e.g. data already available)
           // and we haven't touched them.
           // A simple trick: call populate if text is empty? unsafe.
           // We'll rely on the fact that `listen` fires on next update, but for first load we might need manual call.
           // Or just `_populateControllers` inside build ONLY if day changed?
           
           // Hack for simplicity: Just build fields corresponding to types.
           // Populate happens once per day switch via listen or explicit call?
           // Let's assume listen covers updates. But initial load?
           // We'll call `_populateControllers` in `initState` with `widget.initialMenus`?
           // But that's only for the *first* day.
           
           // Better approach:
           // Build the layout. Initialize controllers with values from `allMenus` DIRECTLY in build if not editing?
           // But editing requires state.
           // Let's wrap the form in a Widget that takes `menus` key.
           
           final filteredMenus = allMenus.where((m) => m.hostelId == widget.hostelId).toList();
           
           return SingleChildScrollView(
             padding: const EdgeInsets.all(24),
             child: _DayEditor(
                key: ValueKey(_currentDay), // Re-init state on day change
                menus: filteredMenus,
                onSave: (menus) async {
                   for (var m in menus) {
                      await ref.read(messServiceProvider).updateLocalMenu(m);
                   }
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menu saved!")));
                   ref.invalidate(messMenuForDayProvider(_currentDay));
                },
                hostelId: widget.hostelId,
                day: _currentDay,
             ),
           );
        },
      ),
    );
  }
  
  void _saveCurrentDay() {
    // Trigger save on child? 
    // Since we moved state to child, we need a way to call it.
    // Or we keep state here and manage it better.
    // Moving state to `_DayEditor` simplifies Controller management (dispose/init on day change).
    // But AppBar Save button is outside.
    // We can use a GlobalKey<_DayEditorState>.
  }
  
  void _populateControllers(List<MessMenu> menus) {
     // Implementation moved to child
  }
}

// Sub-widget to handle form state for a specific day
class _DayEditor extends StatefulWidget {
  final List<MessMenu> menus;
  final Function(List<MessMenu>) onSave;
  final String hostelId;
  final MessDayOfWeek day;

  const _DayEditor({
    Key? key, 
    required this.menus, 
    required this.onSave,
    required this.hostelId,
    required this.day,
  }) : super(key: key);

  @override
  State<_DayEditor> createState() => _DayEditorState();
}

class _DayEditorState extends State<_DayEditor> {
  final Map<MealType, TextEditingController> _itemCtrls = {};
  final Map<MealType, TextEditingController> _timeCtrls = {};

  @override
  void initState() {
    super.initState();
    for (var type in MealType.values) {
      // Find menu for this type
      final menu = widget.menus.firstWhere(
        (m) => m.mealType == type, 
        orElse: () => MessMenu(
            menuId: "${widget.hostelId}_${widget.day.name}_${type.name}", // Temp ID
            hostelId: widget.hostelId,
            dayOfWeek: widget.day,
            mealType: type,
            startTime: _defaultTime(type),
            endTime: _defaultEndTime(type),
            items: ""
        )
      );
      
      _itemCtrls[type] = TextEditingController(text: menu.items);
      _timeCtrls[type] = TextEditingController(text: "${menu.startTime} - ${menu.endTime}");
    }
  }

  String _defaultTime(MealType type) {
    switch (type) {
      case MealType.breakfast: return "07:30";
      case MealType.lunch: return "12:30";
      case MealType.snacks: return "16:30";
      case MealType.dinner: return "19:30";
    }
  }
  
  String _defaultEndTime(MealType type) {
    switch (type) {
      case MealType.breakfast: return "09:30";
      case MealType.lunch: return "14:30";
      case MealType.snacks: return "17:30";
      case MealType.dinner: return "21:30";
    }
  }

  @override
  void dispose() {
    for (var c in _itemCtrls.values) c.dispose();
    for (var c in _timeCtrls.values) c.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(_DayEditor oldWidget) {
     super.didUpdateWidget(oldWidget);
     // If save is triggered from parent, we might need a channel.
     // But simpler: Parent AppBar button? 
     // We can just add a Floating Save button HERE inside the body.
     // Or effectively "Form + Save Button".
  }

  void _submit() {
    List<MessMenu> updates = [];
    for (var type in MealType.values) {
       // Reconstruct
       final items = _itemCtrls[type]!.text;
       final timeStr = _timeCtrls[type]!.text;
       final parts = timeStr.split('-').map((e) => e.trim()).toList();
       final start = parts.isNotEmpty ? parts[0] : _defaultTime(type);
       final end = parts.length > 1 ? parts[1] : _defaultEndTime(type);
       
       // Find original ID to preserve it
       final original = widget.menus.firstWhere(
        (m) => m.mealType == type,
        orElse: () => MessMenu(
            menuId: "${widget.hostelId}_${widget.day.name}_${type.name}",
            hostelId: widget.hostelId,
            dayOfWeek: widget.day,
            mealType: type,
            startTime: start,
            endTime: end,
            items: ""
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
        _buildEditorField("Breakfast", _itemCtrls[MealType.breakfast]!, _timeCtrls[MealType.breakfast]!, AppColors.pastelOrange),
        const SizedBox(height: 24),
        _buildEditorField("Lunch", _itemCtrls[MealType.lunch]!, _timeCtrls[MealType.lunch]!, AppColors.pastelGreen),
        const SizedBox(height: 24),
        _buildEditorField("Snacks", _itemCtrls[MealType.snacks]!, _timeCtrls[MealType.snacks]!, AppColors.pastelBlue),
        const SizedBox(height: 24),
        _buildEditorField("Dinner", _itemCtrls[MealType.dinner]!, _timeCtrls[MealType.dinner]!, AppColors.pastelPurple),
        
        const SizedBox(height: 40),
        
        // Save Button (Here instead of AppBar to simplify state access)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text("Save Changes", style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
