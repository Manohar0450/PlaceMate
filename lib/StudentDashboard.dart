import 'package:flutter/material.dart';
import 'StudentHomeScreen.dart';
// import 'ApplyPage.dart';
import 'PlacementCard.dart';// Ensure this matches your file name
import 'SPlacementsPage.dart'; // Ensure this matches your file name
import 'SettingsPage.dart';

class StudentDashboard extends StatefulWidget {
  final String email;
  const StudentDashboard({super.key, required this.email});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  // Logic to extract name from email (e.g., aditi.sharma@gmail.com -> Aditi Sharma)
  String get studentName {
    try {
      String namePart = widget.email.split('@')[0];
      return namePart.split('.').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ');
    } catch (e) {
      return "Student";
    }
  }

  // The pages list is initialized in initState to pass the studentName
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      StudentHomeScreen(name: studentName), // Dashboard Index 0
      const ApplyPage(),                   // Apply Index 1
      const PlacementsPage(),              // Placements Index 2
      const SettingsPage(),                // Settings Index 3
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      /// --- SHARED APPBAR ---
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
                    const Row(
                      children: [
                        Icon(Icons.school_outlined, size: 16, color: Colors.teal),
                        SizedBox(width: 4),
                        Text("Student",
                            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    Text("Dashboard",
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),

                /// --- CLICKABLE PROFILE TAG ---
                _profileTag(theme),
              ],
            ),
          ),
        ),
      ),

      /// --- DYNAMIC BODY ---
      body: _pages[_selectedIndex],

      /// --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Apply'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Placements'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }

  /// --- UI HELPER: PROFILE TAG ---
  Widget _profileTag(ThemeData theme) {
    return GestureDetector(
      // Tapping the profile tag sets index to 3 (Settings Page)
      onTap: () {
        setState(() {
          _selectedIndex = 3;
        });
      },
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
                const Text("Profile",
                    style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text(studentName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(studentName[0],
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}