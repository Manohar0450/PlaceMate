import 'package:flutter/material.dart';
import 'AIProcessingScreen.dart';
import 'PlacementListScreen.dart';
import 'SettingsPage.dart';
import 'StudentsPageC.dart'; // Ensure this matches your file name

class CoordinatorDashboard extends StatefulWidget {
  final String email;
  final String name;
  final String coordinatorId;

  const CoordinatorDashboard({
    super.key,
    required this.email,
    required this.name,
    required this.coordinatorId
  });

  @override
  State<CoordinatorDashboard> createState() => _CoordinatorDashboardState();
}

class _CoordinatorDashboardState extends State<CoordinatorDashboard> {
  int _selectedIndex = 0;

  String get coordinatorName {
    if (widget.name.isNotEmpty && widget.name != "Coordinator") {
      return "Mr. ${widget.name}";
    }
    try {
      String namePart = widget.email.split('@')[0];
      return "Mr. " + namePart.split('.').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ');
    } catch (e) {
      return "Mr. Coordinator";
    }
  }

  // --- UPDATED GETTER: Correctly passing ID to sub-pages ---
  List<Widget> get _pages => [
    // Index 0: Dashboard (Placement List)
    PlacementListScreen(coordinatorId: widget.coordinatorId),

    // Index 1: Students - NOW PASSING coordinatorId
    StudentsPage(coordinatorId: widget.coordinatorId),

    // Index 2: AI Processing
    AIProcessingScreen(coordinatorId: widget.coordinatorId),

    // Index 3: Settings
     SettingsPage(userId: widget.coordinatorId, userRole: "coordinator"),
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
                        Icon(Icons.group_outlined, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                            "Coordinator",
                            style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                            )
                        ),
                      ],
                    ),
                    Text(
                        "Dashboard",
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold
                        )
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

  Widget _profileTag(ThemeData theme) {
    return GestureDetector(
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
                const Text(
                    "Profile",
                    style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)
                ),
                Text(
                    coordinatorName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                ),
              ],
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                  coordinatorName.split(' ').last.isNotEmpty
                      ? coordinatorName.split(' ').last[0]
                      : "C",
                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)
              ),
            )
          ],
        ),
      ),
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
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Students'),
        BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'AI'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
    );
  }
}