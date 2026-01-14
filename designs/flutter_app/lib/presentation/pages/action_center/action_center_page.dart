import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';
import 'package:adsum/presentation/providers/action_center_provider.dart';

class ActionCenterPage extends ConsumerStatefulWidget {
  const ActionCenterPage({super.key});

  @override
  ConsumerState<ActionCenterPage> createState() => _ActionCenterPageState();
}

class _ActionCenterPageState extends ConsumerState<ActionCenterPage> {
  int _selectedTab = 0; 

  final List<Map<String, dynamic>> _historyLog = [
    {
      'type': 'CONFLICT',
      'title': 'Conflict Resolved',
      'desc': 'Kept Gym over Math',
      'timestamp': 'Yesterday',
      'status': 'KEPT B',
      'icon': Ionicons.person
    },
    {
      'type': 'VERIFY',
      'title': 'Verified Present',
      'desc': 'Mobile App Design',
      'timestamp': 'Oct 20',
      'status': 'YES',
      'icon': Ionicons.checkmark_circle
    },
    {
      'type': 'CHANGE',
      'title': 'Change Seen',
      'desc': 'CS101 Rescheduled',
      'timestamp': 'Oct 19',
      'status': 'SEEN',
      'icon': Ionicons.eye
    }
  ];

  @override
  Widget build(BuildContext context) {
    final asyncActionItems = ref.watch(actionCenterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildMinimalHeader(context),
            // Pass asyncActionItems to build title to show count correctly
            asyncActionItems.when(
              data: (items) => _buildPageTitle(items.length),
              loading: () => _buildPageTitle(0),
              error: (_,__) => _buildPageTitle(0),
            ),
            const SizedBox(height: 24),
            _buildTabSelector(asyncActionItems.value?.isNotEmpty ?? false),
            const SizedBox(height: 24),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selectedTab == 0 
                  ? asyncActionItems.when(
                      data: (items) => _buildActiveList(items),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                    )
                  : _buildHistoryList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 24, top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Ionicons.chevron_back, size: 28),
            onPressed: () => context.pop(),
            style: IconButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300)),
            child: const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=attaullah"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageTitle(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Action Center", style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black, height: 1.1)),
            const SizedBox(height: 6),
            if (_selectedTab == 0)
              Text("$count items pending", style: GoogleFonts.dmSans(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500))
            else
              Text("Audit log of past actions", style: GoogleFonts.dmSans(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector(bool hasActiveItems) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildTabPill("Pending", 0, true, hasActiveItems),
          const SizedBox(width: 12),
          _buildTabPill("History", 1, false, false),
        ],
      ),
    );
  }

  Widget _buildTabPill(String text, int index, bool showIndicator, bool hasItems) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: isSelected ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          children: [
            Text(
              text,
              style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? Colors.white : Colors.grey[600]),
            ),
            if (showIndicator && hasItems) ...[
              const SizedBox(width: 8),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildActiveList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Ionicons.checkmark_done_circle, size: 64, color: Colors.green.shade200),
            const SizedBox(height: 16),
            Text("All clear!", style: GoogleFonts.dmSans(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final item = items[index];
        if (item['type'] == 'CONFLICT') {
          return _buildConflictCard(item);
        } else {
          return _buildGenericActionCard(item);
        }
      },
    );
  }

  // --- CARD 1: CONFLCIT (Complex Split View) ---
  Widget _buildConflictCard(Map<String, dynamic> item) {
    final Color bg = item['bg'] ?? Colors.grey.shade100;
    final Color accent = item['accent'] ?? Colors.black;
    final payload = item['payload'];
    
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(40)),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Schedule Clash", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text(item['date'], style: GoogleFonts.dmSans(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                child: const Icon(Ionicons.alert, size: 20, color: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 24),
          
          // Split View
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: accent.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))]
            ),
            child: Row(
              children: [
                Expanded(child: _buildComparisonItem(payload['sourceA'], accent, true)),
                 Container(width: 1, height: 48, color: Colors.grey.withOpacity(0.15), margin: const EdgeInsets.symmetric(horizontal: 16)),
                Expanded(child: _buildComparisonItem(payload['sourceB'], Colors.grey.shade800, false)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildActionButton("Keep Mine", Colors.white.withOpacity(0.6), Colors.black87, () => _handleAction(item, 'Keep Mine'))),
              const SizedBox(width: 12),
              Expanded(child: _buildActionButton("Accept Update", Colors.white, accent, () => _handleAction(item, 'Accept'))),
            ],
          )
        ],
      ),
    );
  }

  // --- CARD 2: GENERIC ACTION (Verify, Change, Assignment) ---
  Widget _buildGenericActionCard(Map<String, dynamic> item) {
    final Color bg = item['bg'] ?? Colors.grey.shade100;
    final Color accent = item['accent'] ?? Colors.black; 
    final payload = item['payload'];

    IconData icon;
    String btn1 = "OK";
    String? btn2;

    if (item['type'] == 'VERIFY') {
      icon = Ionicons.help_circle;
      btn1 = "Yes, Present";
      btn2 = "No, Absent";
    } else if (item['type'] == 'ASSIGNMENT_DUE') {
      icon = Ionicons.document_text;
      btn1 = "Mark Done";
      btn2 = "Snooze";
    } else if (item['type'] == 'ATTENDANCE_RISK') {
      icon = Ionicons.warning;
      btn1 = "Details";
    } else {
      icon = Ionicons.information_circle; // Schedule Change
      btn1 = "Acknowledge";
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: accent.withOpacity(0.2), shape: BoxShape.circle),
                    child: Icon(icon, size: 20, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'], style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text(item['date'], style: GoogleFonts.dmSans(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          if (item['type'] == 'VERIFY') ...[
             Text(payload['message'], style: GoogleFonts.dmSans(fontSize: 15, color: Colors.black87, height: 1.4)),
             const SizedBox(height: 4),
             if (payload['course'] != null)
              Text(payload['course'], style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: accent)),
          ],
          if (item['type'] == 'SCHEDULE_CHANGE') ...[
             Text(payload['message'], style: GoogleFonts.dmSans(fontSize: 15, color: Colors.black87, height: 1.4)),
          ],
          if (item['type'] == 'ASSIGNMENT_DUE') ...[
             Text("Course: ${payload['course']}", style: GoogleFonts.dmSans(color: Colors.black54, fontSize: 13)),
             Text(payload['work'], style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
             const SizedBox(height: 4),
             Text(payload['due_text'], style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: accent)),
          ],
           if (item['type'] == 'ATTENDANCE_RISK') ...[
             Text("Course: ${payload['course']}", style: GoogleFonts.dmSans(color: Colors.black54, fontSize: 13)),
             Text(payload['message'], style: GoogleFonts.dmSans(fontSize: 15, color: Colors.black87, height: 1.4)),
             const SizedBox(height: 4),
             if (payload['current_per'] != null)
              Text("Current: ${payload['current_per']}", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: accent)),
          ],
          
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildActionButton(btn1, Colors.white, accent, () => _handleAction(item, btn1))),
              if (btn2 != null) ...[
                const SizedBox(width: 12),
                Expanded(child: _buildActionButton(btn2!, Colors.white.withOpacity(0.6), Colors.black87, () => _handleAction(item, btn2!))),
              ]
            ],
          )
        ],
      ),
    );
  }

  Widget _buildComparisonItem(Map<String, dynamic> item, Color accentColor, bool isLeft) {
    return Column(
      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(item['label'].toUpperCase(), style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: accentColor))
        ),
        const SizedBox(height: 8),
        Text(item['title'], style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: isLeft ? TextAlign.left : TextAlign.right),
        Text(item['subtitle'], style: GoogleFonts.dmSans(fontSize: 12, color: Colors.black45), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: isLeft ? TextAlign.left : TextAlign.right),
      ],
    );
  }

  Widget _buildActionButton(String label, Color bg, Color textColor, VoidCallback onTap) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  void _handleAction(Map<String, dynamic> item, String action) {
    ref.read(actionCenterProvider.notifier).resolveItem(item['item_id'], action);
    
    setState(() {
      _historyLog.insert(0, {
        'type': item['type'],
        'title': item['title'],
        'desc': "Action taken: $action",
        'timestamp': "Just now",
        'status': action.toUpperCase(),
        'icon': Ionicons.checkmark_circle
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$action processed"), behavior: SnackBarBehavior.floating));
  }
  
  Widget _buildHistoryList() {
    if (_historyLog.isEmpty) {
      return Center(child: Text("No history yet", style: GoogleFonts.dmSans(color: Colors.grey)));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _historyLog.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (ctx, i) {
        final item = _historyLog[i];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade100)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(item['icon'], size: 18, color: Colors.black54),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'], style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 2),
                    Text(item['desc'] ?? '', style: GoogleFonts.dmSans(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 2),
                    Text(item['timestamp'] ?? '', style: GoogleFonts.dmSans(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(item['status'] ?? '', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            ],
          ),
        );
      },
    );
  }
}
