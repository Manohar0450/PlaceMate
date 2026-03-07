import 'package:flutter/material.dart';

class StudentHomeScreen extends StatelessWidget {
  final Map<String, dynamic> studentData; // RECEIVED: Full data from login

  const StudentHomeScreen({super.key, required this.studentData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Extracting dynamic data from the map
    String name = studentData['name'] ?? "Student";
    String dept = studentData['dept'] ?? "N/A";
    String risk = studentData['risk'] ?? "Low";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Placement Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$dept Department",
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                const Text("Your placement status",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("Risk Level: ",
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    _riskText(risk), // Dynamic Risk display
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          /// Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _statTile(theme, "Applied", "5"),
              _statTile(theme, "Attended", "3"),
              _statTile(theme, "Shortlisted", "1"), // Updated from "Placed" for realism
              _statTile(theme, "Eligible", "Yes"),
            ],
          ),
          const SizedBox(height: 24),

          /// Weekly Activity Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Recent Activity",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 20),
                _activityRow(theme, Icons.verified_user_outlined, "Account verified", Colors.blue),
                _activityRow(theme, Icons.warning_amber_rounded, "Risk updated by Coordinator", Colors.orange),
                _activityRow(theme, Icons.business_center_outlined, "New placement matched", Colors.teal),
                _activityRow(theme, Icons.check_circle_outline, "Applied successfully", Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to color-code the Risk Level text
  Widget _riskText(String level) {
    Color color = level == 'High' ? Colors.red : level == 'Medium' ? Colors.orange : Colors.green;
    return Text(
      level,
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  Widget _statTile(ThemeData theme, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _activityRow(ThemeData theme, IconData icon, String label, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}