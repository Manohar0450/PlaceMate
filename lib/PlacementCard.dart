import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacementCard extends StatefulWidget {
  final Map<String, dynamic> studentData;
  final String company;
  final String role;
  final String lpa;
  final bool isEligible;
  final bool alreadyApplied; // New property to track state from parent

  const PlacementCard({
    super.key,
    required this.studentData,
    required this.company,
    required this.role,
    required this.lpa,
    required this.isEligible,
    this.alreadyApplied = false,
  });

  @override
  State<PlacementCard> createState() => _PlacementCardState();
}

class _PlacementCardState extends State<PlacementCard> {
  late bool _isApplied;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isApplied = widget.alreadyApplied;
  }

  // --- API CALL: Submit Application ---
  Future<void> _handleApply() async {
    if (!widget.isEligible || _isApplied || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse("https://placemate-backend-coral.vercel.app/apply-job"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "rollId": widget.studentData['rollId'],
          "studentName": widget.studentData['name'],
          "companyName": widget.company,
          "role": widget.role,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _isApplied = true;
          _isSubmitting = false;
        });
        _showSnackBar("Applied successfully to ${widget.company}!", Colors.green);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _showSnackBar("Connection failed. Try again.", Colors.red);
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.company,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text("${widget.role}  •  ${widget.lpa}",
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              _statusBadge(widget.isEligible),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.business_center_outlined, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text("Hiring now",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              SizedBox(
                width: 130,
                child: ElevatedButton(
                  onPressed: widget.isEligible ? _handleApply : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isApplied ? Colors.green : theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 16, width: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isApplied ? Icons.check_circle : Icons.send_rounded, size: 16),
                      const SizedBox(width: 8),
                      Text(_isApplied ? "Done" : "Apply",
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
        eligible ? "Eligible" : "Ineligible",
        style: TextStyle(
          color: eligible ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

class ApplyPage extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const ApplyPage({super.key, required this.studentData});

  @override
  State<ApplyPage> createState() => _ApplyPageState();
}
class _ApplyPageState extends State<ApplyPage> {
  final String baseUrl = "https://placemate-backend-coral.vercel.app";
  List<dynamic> allPlacements = [];
  List<dynamic> filteredPlacements = [];
  List<String> userAppliedCompanies = []; // Track where user already applied
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  // --- INITIAL LOAD: Get Placements + User Applications ---
  Future<void> _loadPageData() async {
    try {
      // 1. Fetch Job Postings
      final jobRes = await http.get(Uri.parse("$baseUrl/all-placements"));

      // 2. Fetch User's existing applications to mark cards as "Done"
      final appRes = await http.get(Uri.parse("$baseUrl/my-applications/${widget.studentData['rollId']}"));

      if (jobRes.statusCode == 200 && appRes.statusCode == 200) {
        final List apps = jsonDecode(appRes.body);
        setState(() {
          allPlacements = jsonDecode(jobRes.body);
          filteredPlacements = allPlacements;
          userAppliedCompanies = apps.map((a) => a['companyName'].toString()).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _filterResults(String query) {
    setState(() {
      filteredPlacements = allPlacements.where((p) {
        final company = p['company'].toString().toLowerCase();
        final role = p['role'].toString().toLowerCase();
        return company.contains(query.toLowerCase()) || role.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _loadPageData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Apply placements",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                const Text("Find your next role",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),

                // --- SEARCH BAR ---
                TextField(
                  controller: _searchController,
                  onChanged: _filterResults,
                  decoration: InputDecoration(
                    hintText: "Search company, role",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                      _searchController.clear();
                      _filterResults("");
                    })
                        : null,
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                if (filteredPlacements.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text("No matching roles found.", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),

                // --- DYNAMIC LIST ---
                ...filteredPlacements.map((p) => PlacementCard(
                  studentData: widget.studentData,
                  company: p['company'] ?? "Unknown",
                  role: p['role'] ?? "N/A",
                  lpa: p['lpa'] ?? "TBD",
                  // Ineligible if Risk is High
                  isEligible: widget.studentData['risk'] != "High",
                  // Pass whether user already applied
                  alreadyApplied: userAppliedCompanies.contains(p['company']),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}