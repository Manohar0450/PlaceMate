import 'package:flutter/material.dart';

class PlacementsPage extends StatelessWidget {
  const PlacementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section matching your screenshot
              const Text("Recent placements",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const Text("Company details",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),

              /// --- CURRENT OPENINGS SECTION ---
              const Text("Active Openings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildCompanyCard(
                theme,
                company: "LG",
                role: "SDE",
                lpa: "8 LPA",
                location: "Bengaluru",
                openings: "12 openings",
                tags: ["React", "UI", "Internship"],
              ),
              _buildCompanyCard(
                theme,
                company: "KUBEROX",
                role: "Dont Know",
                lpa: "2 LPA",
                location: "HYD",
                openings: "18 openings",
                tags: ["Testing", "Automation"],
              ),

              const SizedBox(height: 32),

              /// --- UPCOMING PLACEMENTS SECTION ---
              const Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 18, color: Colors.orangeAccent),
                  SizedBox(width: 8),
                  Text("Upcoming",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                ],
              ),
              const SizedBox(height: 16),
              _buildUpcomingCard(
                theme,
                company: "Phillips",
                role: "Cloud Engineer",
                date: "Visiting Feb 10",
                lpa: "12 LPA",
              ),
              _buildUpcomingCard(
                theme,
                company: "IDEA",
                role: "Backend Intern",
                date: "Visiting Feb 15",
                lpa: "9 LPA",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyCard(ThemeData theme, {
    required String company,
    required String role,
    required String lpa,
    required String location,
    required String openings,
    required List<String> tags,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(company, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              _badge(openings, theme),
            ],
          ),
          Text("$role    $lpa", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: tags.map((tag) => _tag(tag, theme)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(ThemeData theme, {
    required String company,
    required String role,
    required String date,
    required String lpa,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.business_outlined, color: Colors.orangeAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(company, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("$role  •  $lpa", style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text(date, style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _badge(String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _tag(String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}