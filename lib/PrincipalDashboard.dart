import 'package:flutter/material.dart';
import 'CoordinatorsPage.dart';
import 'RiskOverviewScreen.dart';
import 'SettingsPage.dart';

class PrincipalDashboard extends StatefulWidget {
  final String name;
  final String principalId;

  const PrincipalDashboard({
    super.key,
    required this.name,
    required this.principalId
  });

  @override
  State<PrincipalDashboard> createState() => _PrincipalDashboardState();
}

class _PrincipalDashboardState extends State<PrincipalDashboard> {
  int _selectedIndex = 0;

  // Logic to handle display name if the email was passed instead of a full name
  String get principalName {
    if (!widget.name.contains('@')) return widget.name;
    try {
      String namePart = widget.name.split('@')[0];
      return namePart.split('.').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ');
    } catch (e) {
      return "Dr. Ananya Rao";
    }
  }


  List<Widget> get _pages => [
    PrincipalHomeScreen(name: principalName), // Index 0
    CoordinatorsPage(currentPrincipalId: widget.principalId), // Index 1: ID PASSED HERE
    const RiskOverviewScreen(),               // Index 2
    const SettingsPage(),                     // Index 3
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      /// --- COMMON APP BAR ---
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
                        Icon(Icons.shield_outlined, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          "Principal",
                          style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Dashboard",
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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

      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, -4)
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF6C9EFF),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded), label: 'Coordinators'),
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Risk'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
        ),
      ),
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
                  principalName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                principalName.isNotEmpty ? principalName[0] : "P",
                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Keep your PrincipalHomeScreen class exactly as it is below...
class PrincipalHomeScreen extends StatelessWidget {
  final String name;
  const PrincipalHomeScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     // Row(
                //     //   children: [
                //     //     Icon(Icons.shield_outlined, size: 16, color: theme.colorScheme.primary),
                //     //     const SizedBox(width: 4),
                //     //     Text("Principal", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                //     //   ],
                //     // ),
                //     // Text("Principal", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                //   ],
                // ),
                // Profile Tag
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                //   decoration: BoxDecoration(
                //     color: theme.cardColor,
                //     borderRadius: BorderRadius.circular(20),
                //     border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                //   ),
                //   child: Row(
                //     children: [
                //       // Column(
                //       //   crossAxisAlignment: CrossAxisAlignment.end,
                //       //   children: [
                //       //     const Text("Profile", style: TextStyle(fontSize: 10, color: Colors.grey)),
                //       //     Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                //       //   ],
                //       // ),
                //       // const SizedBox(width: 10),
                //       // CircleAvatar(
                //       //   radius: 18,
                //       //   backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                //       //   child: Text(name[0], style: TextStyle(color: theme.colorScheme.primary)),
                //       // )
                //     ],
                //   ),
                // )
              ],
            ),

            const SizedBox(height: 24),

            /// Semester at a Glance Card
            _infoCard(
              theme,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Placement analytics", style: theme.textTheme.bodyMedium),
                      Text("This semester at a\nglance",
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 24)),
                    ],
                  ),
                  _liveBadge(theme),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Stats Grid
            Row(
              children: [
                Expanded(child: _statCard(theme, "Placed", "0", "0")),
                const SizedBox(width: 16),
                Expanded(child: _statCard(theme, "Eligible", "0", "0%")),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _statCard(theme, "At risk", "0", "0%", isNegative: true)),
                const SizedBox(width: 16),
                Expanded(child: _statCard(theme, "Companies", "0", "0")),
              ],
            ),

            const SizedBox(height: 24),

            /// Pipeline Card
            _infoCard(
              theme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Placement pipeline", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text("Weekly conversion snapshot", style: theme.textTheme.bodySmall),
                        ],
                      ),
                      Text("Details ↗", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _pipelineRow("Applied", 0, 0, theme),
                  _pipelineRow("Attended", 0, 0, theme),
                  _pipelineRow("Offered", 0, 0, theme),
                  _pipelineRow("Placed", 0, 0, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI Components
  Widget _infoCard(ThemeData theme, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  Widget _statCard(ThemeData theme, String label, String val, String trend, {bool isNegative = false}) {
    return _infoCard(theme, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
              child: Text(trend, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text(val, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    ));
  }

  Widget _liveBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(radius: 3, backgroundColor: Colors.green),
          SizedBox(width: 6),
          Text("Live view", style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _pipelineRow(String label, int count, double progress, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.dividerColor.withOpacity(0.1),
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}