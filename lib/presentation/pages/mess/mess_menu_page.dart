import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:adsum/presentation/pages/mess/menu_editor_page.dart';
import 'package:intl/intl.dart';

class MessMenuPage extends ConsumerStatefulWidget {
  const MessMenuPage({super.key});

  @override
  ConsumerState<MessMenuPage> createState() => _MessMenuPageState();
}

class _MessMenuPageState extends ConsumerState<MessMenuPage> {
  String _selectedHostel = "Kumaon Hostel"; // Default to Kumaon (matches test data)
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize hostel from service (optional, fire and forget)
    ref.read(messServiceProvider).getCurrentHostelId().then((id) {
       if (id != null) setState(() => _selectedHostel = _mapIdToName(id));
    });
  }

  String _mapIdToName(String id) {
     // Map hostel IDs to display names
     switch (id) {
       case 'h_kumaon': return "Kumaon Hostel";
       case 'h_aravali': return "Aravali Hostel";
       case 'h_girnar': return "Girnar Hostel";
       default: return id;
     }
  }
  
  String _mapNameToId(String name) {
     switch (name) {
       case "Kumaon Hostel": return 'h_kumaon';
       case "Aravali Hostel": return 'h_aravali';
       case "Girnar Hostel": return 'h_girnar';
       default: return name.toLowerCase().replaceAll(' ', '_');
     }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Determine Day
    final dayOfWeek = MessDayOfWeek.fromDateTime(_selectedDate);
    
    // 2. Watch Menus for Day
    final menusAsync = ref.watch(messMenuForDayProvider(dayOfWeek));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: _buildHostelSelector(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header (Clickable)
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context, 
                  initialDate: _selectedDate, 
                  firstDate: DateTime(2025), 
                  lastDate: DateTime(2030)
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Menu", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text(
                            _formatDate(_selectedDate), 
                            style: GoogleFonts.dmSans(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)
                          ),
                          const Icon(Ionicons.chevron_down, size: 14, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.bgApp,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Ionicons.calendar, color: Colors.black),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Dynamic Meal Cards
            menusAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading menu: $err')),
              data: (menus) {
                 if (menus.isEmpty) {
                    return Center(child: Text("No menu found for this day.", style: GoogleFonts.dmSans(color: Colors.grey)));
                 }
                 
                 // Filter by hostel locally if provider returns all?
                 // Service getMenusForDay takes optional hostelId. We used family ONLY with day.
                 // So provider returns ALL hostels? Let's check provider def...
                 // `return service.getMenusForDay(day);` -> calls service without hostelId (unless service default uses cache current).
                 // Service `getMenusForDay` implementation: `if (hostelId != null && m.hostelId != hostelId) return false;`.
                 // So if hostelId is null, it returns ALL. We need to filter by `_selectedHostel`.
                 
                 final hostelId = _mapNameToId(_selectedHostel);
                 final hostelMenus = menus.where((m) => m.hostelId == hostelId).toList();
                 
                 if (hostelMenus.isEmpty) {
                    return Center(child: Column(
                      children: [
                         const SizedBox(height: 40),
                         Icon(Ionicons.restaurant_outline, size: 48, color: Colors.grey[300]),
                         const SizedBox(height: 16),
                         Text("No menu data for $_selectedHostel", style: GoogleFonts.dmSans(color: Colors.grey)),
                      ],
                    ));
                 }
                 
                 // Sort by meal type
                 hostelMenus.sort((a,b) => _mealIndex(a.mealType).compareTo(_mealIndex(b.mealType)));

                 return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: hostelMenus.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final menu = hostelMenus[index];
                    return FadeSlideTransition(
                      index: index,
                      child: _buildMealCard(menu),
                    );
                  },
                );
              }
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Check data availability first
          final menusVal = menusAsync.asData?.value;
          if (menusVal == null) return;
          
          final hostelId = _mapNameToId(_selectedHostel);
          final hostelMenus = menusVal.where((m) => m.hostelId == hostelId).toList();

          // Edit Menu
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuEditorPage(
                initialMenus: hostelMenus,
                day: dayOfWeek,
                hostelId: hostelId,
              )
            )
          );
          
          // Refresh
          ref.invalidate(messMenuForDayProvider);
          // Also messServiceProvider usually updates cache which updates queries.
        },
        backgroundColor: Colors.black,
        icon: const Icon(Ionicons.create_outline, color: Colors.white),
        label: Text("Edit Menu", style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  int _mealIndex(MealType type) {
    switch (type) {
      case MealType.breakfast: return 0;
      case MealType.lunch: return 1;
      case MealType.snacks: return 2;
      case MealType.dinner: return 3;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat("E, d MMM").format(date);
  }

  Widget _buildHostelSelector() {
    return PopupMenuButton<String>(
      onSelected: (value) {
         setState(() => _selectedHostel = value);
         // Update Global Preference
         ref.read(messServiceProvider).setCurrentHostelId(_mapNameToId(value));
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: "Kumaon Hostel", child: Text("Kumaon Hostel")),
        const PopupMenuItem(value: "Aravali Hostel", child: Text("Aravali Hostel")),
        const PopupMenuItem(value: "Girnar Hostel", child: Text("Girnar Hostel")),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgApp,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedHostel, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 4),
            const Icon(Ionicons.chevron_down, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(MessMenu menu) {
    // Determine status
    String status = "Upcoming";
    // Basic time check (mock logic for now since string parsing is complex without strict format)
    // In real app, parse `menu.startTime` (HH:mm)
    
    Color color;
    IconData icon;
    
    switch (menu.mealType) {
      case MealType.breakfast:
         color = AppColors.pastelOrange;
         icon = Ionicons.sunny;
         break;
      case MealType.lunch:
         color = AppColors.pastelGreen;
         icon = Ionicons.restaurant;
         break;
      case MealType.snacks:
         color = AppColors.pastelBlue;
         icon = Ionicons.cafe;
         break;
      case MealType.dinner:
         color = AppColors.pastelPurple;
         icon = Ionicons.moon;
         break;
    }
    
    // Check if Modified
    bool isModified = menu.isModified;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(32),
        border: isModified ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(icon, size: 20, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(menu.mealType.displayName, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("${menu.startTime} - ${menu.endTime}", style: GoogleFonts.dmSans(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
              if (isModified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("Edited", style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                )
            ],
          ),
          const SizedBox(height: 20),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: menu.itemsList.map((item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(item, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500)),
            )).toList(),
          )
        ],
      ),
    );
  }
}
