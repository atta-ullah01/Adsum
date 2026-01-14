import 'package:adsum/core/theme/app_colors.dart';
import 'package:adsum/presentation/widgets/animations/fade_slide_transition.dart';
import 'package:adsum/presentation/pages/courses/courses_page.dart'; // Added
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:go_router/go_router.dart';

class AcademicsPage extends StatelessWidget {
  const AcademicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for All Subject List
    final List<Map<String, dynamic>> courses = [
      {
        "title": "Mobile App Design",
        "code": "CS-302",
        "percent": 0.90,
        "color": AppColors.pastelPurple,
        "bgDark": Colors.deepPurple,
        "bunks": 4, // Safe
        "isCustomCourse": false,
      },
      {
        "title": "Theory of Computation",
        "code": "CS-305",
        "percent": 0.72,
        "color": AppColors.pastelOrange, // Warning color
        "bgDark": Colors.deepOrange,
        "recover": 2, // Needs recovery
        "isCustomCourse": false,
      },
      {
        "title": "Computer Networks",
        "code": "CS-304",
        "percent": 0.78,
        "color": AppColors.pastelBlue,
        "bgDark": Colors.blue[800],
        "bunks": 1,
        "isCustomCourse": false,
      },
      {
         "title": "Graph Theory",
         "code": "MA-401",
         "percent": 0.95,
         "color": AppColors.pastelGreen,
         "bgDark": Colors.green[800],
         "bunks": 10,
         "isCustomCourse": false,
      },
      {
         "title": "My Private Elective",
         "code": "CUSTOM-001",
         "percent": 0.80,
         "color": const Color(0xFFFFE0B2), // Light orange
         "bgDark": Colors.orange[800],
         "bunks": 5,
         "isCustomCourse": true, // Custom course!
      }
    ];

    return Scaffold(
      backgroundColor: Colors.white, // Clean white bg
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Ionicons.arrow_back, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text("Academics", style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                           Text("Your Session Progress", style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    // Assignments Link
                    GestureDetector(
                      onTap: () => context.push('/assignments'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                         child: const Icon(Ionicons.list, color: Colors.blue, size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const CircleAvatar(
                      backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=adsum"),
                      radius: 20,
                    )
                  ],
                ),
              ),
              
              // 1. Smart Stats Card (Premium)
              FadeSlideTransition(
                index: 0,
                child: _buildSummaryCard(courses),
              ),
              
              const SizedBox(height: 32),
              
              // 2. Course List Header
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text("Enrolled Courses", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                   Text("${courses.length} Active", style: GoogleFonts.dmSans(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                 ],
               ),
               const SizedBox(height: 16),
               
               // 3. Vertical List of Horizontal Pastel Cards
               ListView.separated(
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: courses.length,
                 separatorBuilder: (c, i) => const SizedBox(height: 16),
                 itemBuilder: (context, index) {
                    final course = courses[index];
                    return FadeSlideTransition(
                      index: index + 1,
                      child: _buildCourseCard(context, course),
                    );
                 },
               ),
               
               const SizedBox(height: 48), // Bottom Padding
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           // Go to Course Management (Standalone)
           Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursesPage(showWizard: false)));
        }, 
        backgroundColor: Colors.black,
        child: const Icon(Ionicons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(List<Map<String, dynamic>> courses) {
    int riskCount = courses.where((c) => c["percent"] < 0.75).length;
    bool isSafe = riskCount == 0;
    
    // Calculate Total Safe Bunks
    int totalBunks = 0;
    for (var c in courses) {
      if (c.containsKey("bunks")) {
        totalBunks += (c["bunks"] as int);
      }
    }
    
    // Colors
    final Color bg = isSafe ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE); // Custom lighter shades
    final Color accent = isSafe ? Colors.green[800]! : Colors.red[800]!;
    final IconData icon = isSafe ? Ionicons.shield_checkmark : Ionicons.warning;

    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          // Decorative Background Icon
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(icon, size: 140, color: accent.withOpacity(0.1)),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.all(8),
                       decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                       child: Icon(icon, size: 16, color: accent),
                     ),
                     const SizedBox(width: 8),
                     Text(
                       isSafe ? "All Good!" : "Action Required",
                       style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: accent, fontSize: 13),
                     ),
                   ],
                 ),
                 const Spacer(),
                 Row(
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [
                     Text(
                       isSafe ? "$totalBunks" : "$riskCount",
                       style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: accent, height: 1.0),
                     ),
                     const SizedBox(width: 12),
                     Padding(
                       padding: const EdgeInsets.only(bottom: 8.0),
                       child: Text(
                         isSafe ? "Safe Bunks\nAvailable" : "Subjects\nat Risk",
                         style: GoogleFonts.dmSans(fontSize: 14, color: accent, fontWeight: FontWeight.w500, height: 1.2),
                       ),
                     )
                   ],
                 )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course) {
    Color bg = course["color"];
    Color textDark = course["bgDark"] ?? Colors.black;
    double percent = course["percent"];
    
    return GestureDetector(
      onTap: () {
        context.push('/subject-detail', extra: {
          'title': course["title"],
          'code': course["code"],
          'isCustomCourse': course["isCustomCourse"] ?? false,
        });
      },
      child: Container(
        // height: 140, // Removed fixed height to prevent bottom overflow
        padding: const EdgeInsets.all(20), // Reduced Padding
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24), // Slightly smaller radius for smaller card
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    course["title"], 
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Ionicons.arrow_forward_circle, color: textDark.withOpacity(0.3), size: 24),
              ],
            ),
            
            const SizedBox(height: 12), // Reduced Spacing
            
            // Stats Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${(percent * 100).toInt()}%",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 32, color: AppColors.textMain),
                ),
                const SizedBox(width: 12),
                Flexible( 
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: course.containsKey("bunks")
                       ? Text("${course['bunks']} Safe Bunks", style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)
                       : Text("Recover ${course['recover']}", style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.danger, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.white.withOpacity(0.5),
                color: AppColors.textMain, // Standard Black/Gray
                minHeight: 8,
              ),
            )
          ],
        ),
      ),
    );
  }
}
