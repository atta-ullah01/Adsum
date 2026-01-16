import 'package:adsum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

class GlobalSearchDelegate extends SearchDelegate {
  final List<String> _recentSearches = [
    'Mobile App Design',
    'Prof. Sarah',
    'Computer Lab 4',
    'Hostel Menu',
  ];

  // Mock Data Source - In real app, this would come from a SearchProvider
  final List<Map<String, dynamic>> _allData = [
    {
      'type': 'Course',
      'title': 'Mobile App Design',
      'subtitle': 'Monday 9:30 AM • LH-102',
      'route': '/subject-detail',
      'args': {'title': 'Mobile App Design', 'code': 'CS3002'}
    },
    {
      'type': 'Course',
      'title': 'Operating Systems',
      'subtitle': 'Tuesday 11:00 AM • LH-1',
      'route': '/subject-detail',
      'args': {'title': 'Operating Systems', 'code': 'CS3001'}
    },
     {
      'type': 'Course',
      'title': 'Data Structures',
      'subtitle': 'Wednesday 10:00 AM • LH-2',
      'route': '/subject-detail',
      'args': {'title': 'Data Structures', 'code': 'CS2001'}
    },
    {
      'type': 'Course',
      'title': 'My Private Elective',
      'subtitle': 'Custom Course • Online',
      'route': '/subject-detail',
      'args': {'title': 'My Private Elective', 'code': 'CUSTOM-001', 'isCustomCourse': true}
    },
    {
      'type': 'Professor',
      'title': 'Prof. Sarah',
      'subtitle': 'Mobile App Design Instructor',
      'route': '/subject-detail', // Mock: Go to their course
      'args': {'title': 'Mobile App Design', 'code': 'CS3002'}
    },
    {
      'type': 'Assignment',
      'title': 'Finance Dashboard',
      'subtitle': 'Due Tomorrow • HCI',
      'route': '/academics/detail',
      'args': {'title': 'Finance Dashboard', 'course': 'HCI', 'deadline': 'Tomorrow', 'status': 'Pending'}
    },
     {
      'type': 'Event',
      'title': 'Hackathon Kickoff',
      'subtitle': 'Auditorium • Friday 5 PM',
      'route': null, 
      'args': null
    },
  ];

  @override
  String get searchFieldLabel => 'Search courses, profs...';

  @override
  TextStyle get searchFieldStyle => GoogleFonts.dmSans(fontSize: 16, color: AppColors.textMain);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        toolbarTextStyle: GoogleFonts.dmSans(color: Colors.black87, fontSize: 18),
        titleTextStyle: GoogleFonts.dmSans(color: Colors.black87, fontSize: 18),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.dmSans(color: Colors.grey.shade400, fontSize: 18),
        border: InputBorder.none,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: Color(0xFFE3F2FD),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Ionicons.close_circle, color: Colors.grey),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Ionicons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResultsList(context, query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentSearches(context);
    }
    return _buildResultsList(context, query);
  }

  Widget _buildRecentSearches(BuildContext context) {
     return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RECENT SEARCHES', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _recentSearches.map((search) => ActionChip(
                elevation: 0,
                backgroundColor: Colors.grey[50],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                avatar: const Icon(Ionicons.time_outline, size: 16, color: Colors.grey),
                label: Text(search, style: GoogleFonts.dmSans(color: Colors.black87, fontWeight: FontWeight.w500)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                onPressed: () {
                  query = search;
                  showResults(context);
                },
              )).toList(),
            ),
          ],
        ),
      );
  }

  Widget _buildResultsList(BuildContext context, String searchQuery) {
    final suggestions = _allData.where((element) {
      final title = (element['title'] as String).toLowerCase();
      final type = (element['type'] as String).toLowerCase();
      final q = searchQuery.toLowerCase();
      return title.contains(q) || type.contains(q);
    }).toList();

    if (suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Ionicons.search, size: 64, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text("No results found for '$searchQuery'", style: GoogleFonts.dmSans(color: Colors.grey)),
          ],
        ),
      );
    }

    return ColoredBox(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
        itemBuilder: (context, index) {
          final item = suggestions[index];
          final type = item['type'] as String;
          final title = item['title'] as String;
          final subtitle = item['subtitle'] as String;
          final route = item['route'] as String?;
          
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getColorForType(type).withOpacity(0.1),
                shape: BoxShape.circle
              ),
              child: Icon(_getIconForType(type), color: _getColorForType(type), size: 20),
            ),
            title: Text(title, style: GoogleFonts.dmSans(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(subtitle, style: GoogleFonts.dmSans(color: Colors.grey, fontSize: 13)),
            onTap: () {
              if (route != null) {
                context.push(route, extra: item['args']);
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Showing details for $title")));
              }
            },
          );
        },
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Course': return AppColors.primary;
      case 'Professor': return Colors.purple;
      case 'Assignment': return Colors.orange;
      case 'Event': return Colors.pink;
      default: return Colors.grey;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Course': return Ionicons.book;
      case 'Professor': return Ionicons.person;
      case 'Assignment': return Ionicons.document_text;
      case 'Event': return Ionicons.calendar;
      default: return Ionicons.search;
    }
  }
}
