
import 'package:flutter/material.dart';
import 'StudentDashboard.dart';
class StudentHomeScreen extends StatelessWidget {

  final String name;
  const StudentHomeScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                const Text("Student dashboard", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const Text("Your placement status", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Text("Eligibility: ", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    Text("Eligible", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          /// Stats Grid (Applied, Attended, Placed, Eligible)
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
              _statTile(theme, "Placed", "1"),
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
                const Text("This week", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 20),
                _activityRow(theme, Icons.verified_user_outlined, "Profile verified", Colors.blue),
                _activityRow(theme, Icons.calendar_today_outlined, "Interview scheduled", Colors.indigo),
                _activityRow(theme, Icons.business_center_outlined, "New placement matched", Colors.blue),
                _activityRow(theme, Icons.check_circle_outline, "Applied successfully", Colors.blue),
              ],
            ),
          ),
        ],
      ),
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
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _activityRow(ThemeData theme, IconData icon, String label, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}