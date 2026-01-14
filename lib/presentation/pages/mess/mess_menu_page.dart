import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:adsum/presentation/pages/mess/menu_editor_page.dart';

class MessMenuPage extends StatefulWidget {
  const MessMenuPage({super.key});

  @override
  State<MessMenuPage> createState() => _MessMenuPageState();
}

class _MessMenuPageState extends State<MessMenuPage> {
  String _selectedHostel = "Hostel H1";
  DateTime _selectedDate = DateTime.now();
  
  // Mock Menu Data (Ordered by time roughly)
  Map<String, List<String>> _menu = {
    "Breakfast": ["Aloo Paratha", "Curd", "Tea/Coffee", "Cornflakes"],
    "Lunch": ["Rice", "Dal Makhani", "Paneer Butter Masala", "Roti", "Salad"],
    "Snacks": ["Samosa", "Tea", "Biscuits"],
    "Dinner": ["Fried Rice", "Manchurian", "Soup", "Ice Cream"],
  };

  final Map<String, String> _mealTimes = {
    "Breakfast": "07:30 - 09:30",
    "Lunch": "12:30 - 14:30",
    "Snacks": "16:30 - 17:30", 
    "Dinner": "19:30 - 21:30"
  };

  final Map<String, Color> _mealColors = {
    "Breakfast": AppColors.pastelOrange,
    "Lunch": AppColors.pastelGreen,
    "Snacks": AppColors.pastelBlue, 
    "Dinner": AppColors.pastelPurple,
  };

  @override
  Widget build(BuildContext context) {
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _menu.length,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                String meal = _menu.keys.elementAt(index);
                List<String> items = _menu[meal]!;
                String time = _mealTimes[meal]!;
                Color color = _mealColors[meal] ?? AppColors.bgApp;
                String status = "Upcoming"; // Mock status logic could be better but keeping simple
                if (meal == "Lunch") status = "Live Now";
                if (meal == "Breakfast") status = "Ended";
                
                return FadeSlideTransition(
                  index: index,
                  child: _buildMealCard(meal, time, items, color, status),
                );
              },
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Edit Menu
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuEditorPage(
                initialMenu: _menu,
                initialTimes: _mealTimes,
              )
            )
          );
          
          if (result != null && result is Map) {
            setState(() {
              if (result['menu'] != null) _menu = result['menu'];
              if (result['times'] != null) {
                  Map<String, String> newTimes = {};
                  (result['times'] as Map).forEach((k, v) => newTimes[k.toString()] = v.toString());
                  _mealTimes.addAll(newTimes);
              }
            });
          }
        },
        backgroundColor: Colors.black,
        icon: const Icon(Ionicons.create_outline, color: Colors.white),
        label: Text("Edit Menu", style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return "${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}";
  }

  Widget _buildHostelSelector() {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => _selectedHostel = value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: "Hostel H1", child: Text("Hostel H1")),
        const PopupMenuItem(value: "Hostel H2", child: Text("Hostel H2")),
        const PopupMenuItem(value: "Girls Hostel A", child: Text("Girls Hostel A")),
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

  Widget _buildMealCard(String title, String time, List<String> items, Color color, String status) {
    bool isLive = status == "Live Now";
    IconData icon = Ionicons.restaurant;
    if (title == "Breakfast") icon = Ionicons.sunny;
    if (title == "Dinner") icon = Ionicons.moon;
    if (title == "Snacks") icon = Ionicons.cafe;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(32),
        border: isLive ? Border.all(color: Colors.black, width: 2) : null,
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
                      Text(title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(time, style: GoogleFonts.dmSans(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isLive ? Colors.black : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: isLive ? Colors.white : Colors.black)),
              )
            ],
          ),
          const SizedBox(height: 20),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) => Container(
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
