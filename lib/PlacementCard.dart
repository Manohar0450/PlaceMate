import 'package:flutter/material.dart';

class PlacementCard extends StatefulWidget {
  final String company;
  final String role;
  final String lpa;
  final bool isEligible;

  const PlacementCard({
    super.key,
    required this.company,
    required this.role,
    required this.lpa,
    required this.isEligible,
  });

  @override
  State<PlacementCard> createState() => _PlacementCardState();
}

class _PlacementCardState extends State<PlacementCard> {
  bool _isApplied = false;

  void _handleApply() {
    if (!widget.isEligible || _isApplied) return;

    setState(() {
      _isApplied = true;
    });

    // Optional: Show a success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Successfully applied to ${widget.company}!"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  Text(widget.company,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("${widget.role}    ${widget.lpa}",
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
              _statusBadge(widget.isEligible),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.business_center_outlined, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text("Hiring now", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: widget.isEligible ? _handleApply : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isApplied ? Colors.green : const Color(0xFF3B82F6),
                    disabledBackgroundColor: Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isApplied ? Icons.check_circle : Icons.check_circle_outline, size: 16),
                      const SizedBox(width: 8),
                      Text(_isApplied ? "Applied" : "Apply",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(bool eligible) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: eligible ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        eligible ? "Eligible" : "Not eligible",
        style: TextStyle(
          color: eligible ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
class ApplyPage extends StatelessWidget {
  const ApplyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Apply placements",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const Text("Find your next role",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: "Search company, role",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Placement List
              const PlacementCard(company: "Ever UP Time", role: "Frontend Intern", lpa: "20 LPA", isEligible: true),
              const PlacementCard(company: "Stats", role: "Data Analyst", lpa: "69 LPA", isEligible: true),
              const PlacementCard(company: "24/7", role: " NON VOICE", lpa: "19 LPA", isEligible: false),
              const PlacementCard(company: "TTEC", role: "NON VOICE", lpa: "12 LPA", isEligible: true),
            ],
          ),
        ),
      ),
    );
  }
}