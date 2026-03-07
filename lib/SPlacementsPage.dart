import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SPlacementsPage extends StatefulWidget {
  const SPlacementsPage({super.key});

  @override
  State<SPlacementsPage> createState() => _SPlacementsPageState();
}

class _SPlacementsPageState extends State<SPlacementsPage> {
  final String baseUrl = "https://placemate-backend-coral.vercel.app";
  List<dynamic> activePlacements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLivePlacements();
  }

  // --- API: Fetch data from MongoDB ---
  Future<void> _fetchLivePlacements() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/all-placements"));
      if (response.statusCode == 200) {
        setState(() {
          activePlacements = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar("Unable to sync placement list", Colors.red);
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _fetchLivePlacements,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Recent placements",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const Text("Company details",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 24),

                /// --- LIVE OPENINGS FROM DATABASE ---
                const Text("Active Openings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                if (activePlacements.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text("No active openings found", style: TextStyle(color: Colors.grey)),
                  )),

                ...activePlacements.map((p) => _buildCompanyCard(
                  theme,
                  company: p['company'] ?? "Unknown",
                  role: p['role'] ?? "N/A",
                  lpa: p['lpa'] ?? "TBD",
                  stage: p['stage'] ?? "Open", // Dynamically showing stage from DB
                )),

                const SizedBox(height: 32),

                /// --- UPCOMING PLACEMENTS SECTION (Static for now) ---
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyCard(ThemeData theme, {
    required String company,
    required String role,
    required String lpa,
    required String stage,
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
              _badge(stage, theme), // Showing 'Open', 'Screening' etc.
            ],
          ),
          const SizedBox(height: 4),
          Text("$role    $lpa", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text("Bengaluru", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              // ElevatedButton(
              //   onPressed: () {}, // Future apply logic
              //   style: ElevatedButton.styleFrom(
              //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              //     minimumSize: const Size(80, 32),
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //   ),
              //   child: const Text("Apply", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  // --- STATIC UI HELPERS ---

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
            decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.1), shape: BoxShape.circle),
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
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.teal)),
    );
  }
}