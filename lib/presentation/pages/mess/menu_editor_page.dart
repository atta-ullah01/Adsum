import 'package:adsum/data/providers/data_providers.dart';
import 'package:adsum/domain/models/models.dart';
import 'package:adsum/presentation/pages/mess/providers/menu_editor_viewmodel.dart';
import 'package:adsum/presentation/pages/mess/widgets/menu_day_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class MenuEditorPage extends ConsumerStatefulWidget {

  const MenuEditorPage({
    required this.day, required this.hostelId, super.key, 
    this.initialMenus
  });
  final List<MessMenu>? initialMenus;
  final MessDayOfWeek day;
  final String hostelId;

  @override
  ConsumerState<MenuEditorPage> createState() => _MenuEditorPageState();
}

class _MenuEditorPageState extends ConsumerState<MenuEditorPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<MessDayOfWeek> _days = MessDayOfWeek.values;

  @override
  void initState() {
    super.initState();
    final initialIndex = _days.indexOf(widget.day);
    _tabController = TabController(length: 7, vsync: this, initialIndex: initialIndex);
    
    // Sync TabController with ViewModel
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
         final newDay = _days[_tabController.index];
         ref.read(menuEditorViewModelProvider(widget.day).notifier).setDay(newDay);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch ViewModel state
    final vmState = ref.watch(menuEditorViewModelProvider(widget.day));
    final currentDay = vmState.selectedDay;
    
    // Watch data for CURRENT day
    final menusAsync = ref.watch(messMenuForDayProvider(currentDay));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Menu', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: const [
          // We removed the Save button here because the form handles it internaly 
          // or we can add back if we use a global key, but keeping it simple as per previous refactor decision
          // actually the previous refactor kept the button in the body.
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          indicatorColor: Colors.black,
          tabs: _days.map((d) => Tab(text: d.name.toUpperCase())).toList(),
          onTap: (index) {
             // Redundant with listener but safe
          },
        ),
      ),
      body: menusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allMenus) {
           final filteredMenus = allMenus.where((m) => m.hostelId == widget.hostelId).toList();
           
           return SingleChildScrollView(
             padding: const EdgeInsets.all(24),
             child: MenuDayEditor(
                key: ValueKey(currentDay), // Force re-init on day change
                menus: filteredMenus,
                onSave: (menus) async {
                   for (final m in menus) {
                      await ref.read(messServiceProvider).updateLocalMenu(m);
                   }
                   if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu saved!')));
                   }
                   ref.invalidate(messMenuForDayProvider(currentDay));
                },
                hostelId: widget.hostelId,
                day: currentDay,
             ),
           );
        },
      ),
    );
  }
}
