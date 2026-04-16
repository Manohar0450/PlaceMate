import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CoordinatorsPage.dart';
import 'RiskOverviewScreen.dart';
import 'SettingsPage.dart';
import 'NotificationPage.dart';

class PrincipalDashboard extends StatefulWidget {
  final String name;
  final String principalId;

  const PrincipalDashboard({
    super.key,
    required this.name,
    required this.principalId,
  });

  @override
  State<PrincipalDashboard> createState() => _PrincipalDashboardState();
}

class _PrincipalDashboardState extends State<PrincipalDashboard> {
  int _selectedIndex = 0;
  int _unreadCount = 0;
  final String baseUrl = "https://placemate-backend-coral.vercel.app";

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/notifications/${widget.principalId}/unread-count"),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _unreadCount = data['count'] ?? 0);
      }
    } catch (_) {}
  }

  String get principalName {
    if (!widget.name.contains('@')) return widget.name;
    try {
      String namePart = widget.name.split('@')[0];
      return namePart
          .split('.')
          .map((s) => s[0].toUpperCase() + s.substring(1))
          .join(' ');
    } catch (e) {
      return "Dr. Manohar";
    }
  }

  List<Widget> get _pages => [
    PrincipalHomeScreen(
      name: principalName,
      principalId: widget.principalId,
    ),
    CoordinatorsPage(currentPrincipalId: widget.principalId),
    const RiskOverviewScreen(),
    SettingsPage(
      userId: widget.principalId,
      userRole: "principal",
    ),
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
                        Icon(Icons.shield_outlined,
                            size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          "Principal",
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Dashboard",
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Notification Bell
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificationPage(
                              userId: widget.principalId,
                              userRole: "principal",
                            ),
                          ),
                        );
                        _fetchUnreadCount();
                      },
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_outlined,
                                size: 22),
                          ),
                          if (_unreadCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "$_unreadCount",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _profileTag(theme),
                  ],
                ),
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
              offset: const Offset(0, -4),
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
          selectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_outline_rounded),
                label: 'Coordinators'),
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: 'Risk'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined), label: 'Settings'),
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
                const Text("Profile",
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold)),
                Text(
                  principalName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 18,
              backgroundColor:
              theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                principalName.isNotEmpty ? principalName[0] : "P",
                style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PRINCIPAL HOME SCREEN — FULLY DYNAMIC
// ─────────────────────────────────────────────────────────────
class PrincipalHomeScreen extends StatefulWidget {
  final String name;
  final String principalId;

  const PrincipalHomeScreen({
    super.key,
    required this.name,
    required this.principalId,
  });

  @override
  State<PrincipalHomeScreen> createState() => _PrincipalHomeScreenState();
}

class _PrincipalHomeScreenState extends State<PrincipalHomeScreen> {
  final String baseUrl = "https://placemate-backend-coral.vercel.app";

  bool isLoading = true;

  // Stats
  int totalCoordinators = 0;
  int totalStudents = 0;
  int placedStudents = 0;
  int atRiskStudents = 0;
  int eligibleStudents = 0;
  int totalCompanies = 0;

  // Pipeline
  int applied = 0;
  int attended = 0;
  int offered = 0;
  int placed = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => isLoading = true);
    try {
      // 1. Fetch coordinators for this principal
      final coordRes = await http.get(
        Uri.parse("$baseUrl/coordinators/${widget.principalId}"),
      );
      List coordinators = [];
      if (coordRes.statusCode == 200) {
        coordinators = jsonDecode(coordRes.body);
      }

      // 2. Fetch all students across all coordinators
      List allStudents = [];
      for (final coord in coordinators) {
        final sRes = await http.get(
          Uri.parse("$baseUrl/students/${coord['_id']}"),
        );
        if (sRes.statusCode == 200) {
          allStudents.addAll(jsonDecode(sRes.body));
        }
      }

      // 3. Fetch all placements
      final pRes = await http.get(Uri.parse("$baseUrl/all-placements"));
      List placements = [];
      if (pRes.statusCode == 200) {
        placements = jsonDecode(pRes.body);
      }

      // 4. Fetch all job applications
      int appApplied = 0, appAttended = 0, appOffered = 0, appPlaced = 0;
      for (final s in allStudents) {
        final aRes = await http.get(
          Uri.parse("$baseUrl/my-applications/${s['rollId']}"),
        );
        if (aRes.statusCode == 200) {
          final apps = jsonDecode(aRes.body) as List;
          appApplied += apps.length;
          for (final app in apps) {
            final status = (app['status'] ?? '').toString().toLowerCase();
            if (status == 'attended') appAttended++;
            if (status == 'offered') appOffered++;
            if (status == 'placed') appPlaced++;
          }
        }
      }

      // 5. Compute risk stats
      int risk = allStudents
          .where((s) =>
      (s['risk'] ?? '').toString().toLowerCase() == 'high')
          .length;
      int eligible = allStudents
          .where((s) =>
      (s['risk'] ?? '').toString().toLowerCase() != 'high')
          .length;

      // Unique companies
      Set<String> companies = {};
      for (final p in placements) {
        if (p['company'] != null) companies.add(p['company'].toString());
      }

      setState(() {
        totalCoordinators = coordinators.length;
        totalStudents = allStudents.length;
        atRiskStudents = risk;
        eligibleStudents = eligible;
        totalCompanies = companies.length;
        placedStudents = appPlaced;
        applied = appApplied;
        attended = appAttended;
        offered = appOffered;
        placed = appPlaced;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state — no coordinators yet
    if (totalCoordinators == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline_rounded,
                  size: 72, color: theme.colorScheme.primary.withOpacity(0.3)),
              const SizedBox(height: 20),
              Text(
                "No data yet",
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Go to Coordinators tab and add your first\ncoordinator to start tracking placements.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadDashboard,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Header card
              _infoCard(
                theme,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Placement analytics",
                            style: theme.textTheme.bodyMedium),
                        Text(
                          "This semester at a\nglance",
                          style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ],
                    ),
                    _liveBadge(theme),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Coordinator count banner
              _infoCard(
                theme,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.people_outline_rounded,
                          color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Active Coordinators",
                            style: theme.textTheme.bodySmall),
                        Text(
                          "$totalCoordinators coordinator${totalCoordinators == 1 ? '' : 's'} managing $totalStudents students",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Stats Grid
              Row(
                children: [
                  Expanded(
                      child: _statCard(theme, "Placed",
                          "$placedStudents", Icons.check_circle_outline,
                          color: Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _statCard(theme, "Eligible",
                          "$eligibleStudents", Icons.verified_outlined,
                          color: Colors.blue)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _statCard(theme, "At Risk",
                          "$atRiskStudents", Icons.warning_amber_rounded,
                          color: Colors.redAccent)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _statCard(theme, "Companies",
                          "$totalCompanies", Icons.business_outlined,
                          color: Colors.purple)),
                ],
              ),

              const SizedBox(height: 20),

              // Pipeline card
              _infoCard(
                theme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Placement Pipeline",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text("Conversion across all students",
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 20),
                    _pipelineRow("Applied", applied,
                        applied == 0 ? 0 : 1.0, theme),
                    _pipelineRow(
                        "Attended",
                        attended,
                        applied == 0
                            ? 0
                            : attended / applied,
                        theme),
                    _pipelineRow(
                        "Offered",
                        offered,
                        applied == 0
                            ? 0
                            : offered / applied,
                        theme),
                    _pipelineRow(
                        "Placed",
                        placed,
                        applied == 0
                            ? 0
                            : placed / applied,
                        theme),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Risk breakdown
              _infoCard(
                theme,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Risk Breakdown",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _riskChip("High Risk", atRiskStudents,
                            Colors.redAccent),
                        _riskChip("Eligible", eligibleStudents,
                            Colors.green),
                        _riskChip("Total", totalStudents,
                            theme.colorScheme.primary),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(ThemeData theme, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  Widget _statCard(ThemeData theme, String label, String val, IconData icon,
      {required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(val,
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold)),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
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

  Widget _pipelineRow(
      String label, int count, double progress, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              Text(count.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: theme.dividerColor.withOpacity(0.1),
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _riskChip(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}