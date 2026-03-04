import 'package:flutter/material.dart';

class RiskOverviewScreen extends StatelessWidget {
  const RiskOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Header Card
            _riskHeader(theme),
            const SizedBox(height: 24),

            /// Student Risk Cards
            _studentRiskCard(
              theme,
              name: "Srinivas",
              dept: "Aiml",
              id: "4233",
              score: 99,
              level: "High",
              color: Colors.redAccent,
              icon: Icons.shield_outlined,
            ),
            _studentRiskCard(
              theme,
              name: "Karthik",
              dept: "CSE",
              id: "4254",
              score: 36,
              level: "Low",
              color: Colors.greenAccent,
              icon: Icons.local_fire_department_outlined,
            ),
            _studentRiskCard(
              theme,
              name: "Manohar",
              dept: "IOT",
              id: "4245",
              score: 66,
              level: "Medium",
              color: Colors.blue,
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _riskHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Student risk monitoring", style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text("Risk overview", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 26)),
                const SizedBox(height: 8),
                const Text("Use this to identify students who need intervention.", style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentRiskCard(
      ThemeData theme, {
        required String name,
        required String dept,
        required String id,
        required int score,
        required String level,
        required Color color,
        required IconData icon,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("$dept    ID $id", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(level, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Risk score", style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text("$score/100", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: theme.dividerColor.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}