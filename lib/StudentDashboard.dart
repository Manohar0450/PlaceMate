import 'package:flutter/material.dart';
import 'StudentHomeScreen.dart';
import 'SPlacementsPage.dart';
import 'SettingsPage.dart';
import 'package:placemate/PlacementCard.dart'; // Ensure this file exists and takes studentData

class StudentDashboard extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const StudentDashboard({super.key, required this.studentData});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  // Real-time getters for data from the Map
  String get studentName => widget.studentData['name'] ?? "Student";
  String get studentId => widget.studentData['rollId'] ?? "0000";

  // Pages list using the getter to pass data and maintain state
  List<Widget> get _pages => [
    StudentHomeScreen(studentData: widget.studentData), // Tab 0
    ApplyPage(studentData: widget.studentData),         // Tab 1: Now integrated
    const SPlacementsPage(),                            // Tab 2: Live Job List
    const SettingsPage(),                               // Tab 3: Settings
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school_outlined, size: 16, color: Colors.teal),
                        const SizedBox(width: 4),
                        Text(
                            "ID: $studentId",
                            style: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                            )
                        ),
                      ],
                    ),
                    Text(
                        "Dashboard",
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
                _profileTag(theme),
              ],
            ),
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(theme),
    );
  }

  Widget _buildBottomNav(ThemeData theme) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.colorScheme.primary,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Dashboard'
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.send_outlined),
            label: 'Apply'
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.business_center_outlined),
            label: 'Placements'
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings'
        ),
      ],
    );
  }

  Widget _profileTag(ThemeData theme) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                    "Profile",
                    style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)
                ),
                Text(
                    studentName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                ),
              ],
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                  studentName.isNotEmpty ? studentName[0].toUpperCase() : "S",
                  style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold
                  )
              ),
            )
          ],
        ),
      ),
    );
  }
}