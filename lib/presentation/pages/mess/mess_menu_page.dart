import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/pages/mess/menu_editor_page.dart';
import 'package:adsum/presentation/pages/mess/providers/mess_menu_viewmodel.dart';
import 'package:adsum/presentation/pages/mess/widgets/mess_meal_card.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

class MessMenuPage extends ConsumerStatefulWidget {
  const MessMenuPage({super.key});

  @override
  ConsumerState<MessMenuPage> createState() => _MessMenuPageState();
}

class _MessMenuPageState extends ConsumerState<MessMenuPage> {
  
  @override
  void initState() {
    super.initState();
    // Initialize hostel from preferences
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messMenuViewModelProvider.notifier).initHostel();
    });
  }

  String _mapIdToName(String id) {
     switch (id) {
       case 'h_kumaon': return 'Kumaon Hostel';
       case 'h_aravali': return 'Aravali Hostel';
       case 'h_girnar': return 'Girnar Hostel';
       default: return id;
     }
  }
  
  String _mapNameToId(String name) {
     switch (name) {
       case 'Kumaon Hostel': return 'h_kumaon';
       case 'Aravali Hostel': return 'h_aravali';
       case 'Girnar Hostel': return 'h_girnar';
       default: return name.toLowerCase().replaceAll(' ', '_');
     }
  }

  int _mealIndex(MealType type) {
    switch (type) {
      case MealType.breakfast: return 0;
      case MealType.lunch: return 1;
      case MealType.snacks: return 2;
      case MealType.dinner: return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(messMenuViewModelProvider);
    final vmNotifier = ref.read(messMenuViewModelProvider.notifier);
    
    // 1. Determine Day
    final dayOfWeek = MessDayOfWeek.fromDateTime(vmState.selectedDate);
    
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
        title: _buildHostelSelector(vmState.selectedHostel, vmNotifier),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context, 
                  initialDate: vmState.selectedDate, 
                  firstDate: DateTime(2025), 
                  lastDate: DateTime(2030)
                );
                if (date != null) vmNotifier.setDate(date);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Menu', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text(
                            DateFormat('E, d MMM').format(vmState.selectedDate), 
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
                    return Center(child: Text('No menu found for this day.', style: GoogleFonts.dmSans(color: Colors.grey)));
                 }
                 
                 final hostelMenus = menus.where((m) => m.hostelId == vmState.selectedHostel).toList();
                 
                 if (hostelMenus.isEmpty) {
                    return Center(child: Column(
                      children: [
                         const SizedBox(height: 40),
                         Icon(Ionicons.restaurant_outline, size: 48, color: Colors.grey[300]),
                         const SizedBox(height: 16),
                         Text('No menu data for ${_mapIdToName(vmState.selectedHostel)}', style: GoogleFonts.dmSans(color: Colors.grey)),
                      ],
                    ));
                 }
                 
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
                      child: MessMealCard(menu: menu),
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
          final menusVal = menusAsync.asData?.value;
          if (menusVal == null) return;
          
          final hostelMenus = menusVal.where((m) => m.hostelId == vmState.selectedHostel).toList();

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuEditorPage(
                initialMenus: hostelMenus,
                day: dayOfWeek,
                hostelId: vmState.selectedHostel,
              )
            )
          );
          
          ref.invalidate(messMenuForDayProvider);
        },
        backgroundColor: Colors.black,
        icon: const Icon(Ionicons.create_outline, color: Colors.white),
        label: Text('Edit Menu', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHostelSelector(String selectedHostelId, MessMenuViewModel notifier) {
    return PopupMenuButton<String>(
      onSelected: (value) => notifier.setHostel(_mapNameToId(value)),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Kumaon Hostel', child: Text('Kumaon Hostel')),
        const PopupMenuItem(value: 'Aravali Hostel', child: Text('Aravali Hostel')),
        const PopupMenuItem(value: 'Girnar Hostel', child: Text('Girnar Hostel')),
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
            Text(_mapIdToName(selectedHostelId), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 4),
            const Icon(Ionicons.chevron_down, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
