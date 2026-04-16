import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'session_manager.dart';

/// Shown in the Principal dashboard (Tab 2).
/// Fetches ALL students from the backend, groups them by risk level,
/// and displays them in a live list.
///
/// If the logged-in user is a coordinator, pass their coordinatorId;
/// for principals we fetch all students by iterating coordinators
/// — but since the backend doesn't have a "get all students" endpoint
/// we just fetch from /students/:coordinatorId stored in session or
/// fall back to showing all students from the principal's coordinators.
///
/// For simplicity this widget accepts an optional coordinatorId.
/// When null (principal view) it shows every student from all coordinators
/// managed under the principal.
class RiskOverviewScreen extends StatefulWidget {
  /// Pass the coordinatorId to scope students to one coordinator,
  /// or null to show students across all coordinators (principal view).
  final String? coordinatorId;

  const RiskOverviewScreen({super.key, this.coordinatorId});

  @override
  State<RiskOverviewScreen> createState() => _RiskOverviewScreenState();
}

class _RiskOverviewScreenState extends State<RiskOverviewScreen> {
  static const String _base = "https://placemate-backend-coral.vercel.app";

  List<Map<String, dynamic>> _allStudents = [];
  bool _isLoading = true;
  String? _error;
  String _filterRisk = "All"; // "All" | "High" | "Medium" | "Low"

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  // ── FETCH ─────────────────────────────────────────────────────────────────
  Future<void> _fetchStudents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (widget.coordinatorId != null) {
        // ── Coordinator view: single API call ─────────────────────────
        await _fetchForCoordinator(widget.coordinatorId!);
      } else {
        // ── Principal view: get coordinators first, then all their students
        await _fetchForPrincipal();
      }
    } catch (e) {
      setState(() => _error = "Failed to load: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchForCoordinator(String coordId) async {
    final res = await http.get(Uri.parse("$_base/students/$coordId"));
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      _allStudents =
          list.map((s) => s as Map<String, dynamic>).toList();
    } else {
      throw Exception("Could not load students");
    }
  }

  Future<void> _fetchForPrincipal() async {
    // Need principalId from session to get its coordinators
    final saved = await SessionManager.getSavedUserData();
    if (saved == null) throw Exception("Session expired");

    final principalId = saved['_id'] as String?;
    if (principalId == null) throw Exception("Principal ID missing");

    // 1. Fetch all coordinators of this principal
    final coordRes = await http.get(
        Uri.parse("$_base/coordinators/$principalId"));
    if (coordRes.statusCode != 200) throw Exception("Could not load coordinators");

    final coordinators = jsonDecode(coordRes.body) as List<dynamic>;

    // 2. Fetch students for each coordinator in parallel
    final futures = coordinators.map((c) async {
      final cId = c['_id'] as String;
      try {
        final sRes =
        await http.get(Uri.parse("$_base/students/$cId"));
        if (sRes.statusCode == 200) {
          return (jsonDecode(sRes.body) as List<dynamic>)
              .map((s) => s as Map<String, dynamic>)
              .toList();
        }
      } catch (_) {}
      return <Map<String, dynamic>>[];
    });

    final results = await Future.wait(futures);
    _allStudents = results.expand((l) => l).toList();

    // Sort by name
    _allStudents.sort((a, b) =>
        (a['name'] as String? ?? "").compareTo(b['name'] as String? ?? ""));
  }

  // ── FILTERED LIST ─────────────────────────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    if (_filterRisk == "All") return _allStudents;
    return _allStudents
        .where((s) =>
    (s['risk'] as String? ?? "Low").toLowerCase() ==
        _filterRisk.toLowerCase())
        .toList();
  }

  // ── COUNTS ────────────────────────────────────────────────────────────────
  int _count(String level) => _allStudents
      .where((s) =>
  (s['risk'] as String? ?? "Low").toLowerCase() ==
      level.toLowerCase())
      .length;

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchStudents,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 20),
              if (!_isLoading && _error == null) ...[
                _buildStatsRow(theme),
                const SizedBox(height: 16),
                _buildFilterChips(),
                const SizedBox(height: 16),
              ],
              _buildBody(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
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
            child: const Icon(Icons.warning_amber_rounded,
                color: Colors.redAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Student risk monitoring",
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text("Risk overview",
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 26)),
                const SizedBox(height: 8),
                const Text(
                  "Identify students who need placement intervention.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      children: [
        _statChip(theme, "Total", _allStudents.length, Colors.blue),
        const SizedBox(width: 8),
        _statChip(theme, "High", _count("High"), Colors.redAccent),
        const SizedBox(width: 8),
        _statChip(theme, "Medium", _count("Medium"), Colors.orange),
        const SizedBox(width: 8),
        _statChip(theme, "Low", _count("Low"), Colors.green),
      ],
    );
  }

  Widget _statChip(ThemeData theme, String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text("$count",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ["All", "High", "Medium", "Low"].map((level) {
          final selected = _filterRisk == level;
          final Color color = level == "High"
              ? Colors.redAccent
              : level == "Medium"
              ? Colors.orange
              : level == "Low"
              ? Colors.green
              : Colors.blue;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(level,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : color)),
              selected: selected,
              onSelected: (_) => setState(() => _filterRisk = level),
              selectedColor: color,
              backgroundColor: color.withOpacity(0.1),
              checkmarkColor: Colors.white,
              side: BorderSide(color: color.withOpacity(0.3)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _fetchStudents,
                  child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.green.withOpacity(0.6), size: 48),
              const SizedBox(height: 12),
              Text(
                _filterRisk == "All"
                    ? "No students found"
                    : "No $_filterRisk risk students",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children:
      list.map((student) => _buildStudentCard(theme, student)).toList(),
    );
  }

  Widget _buildStudentCard(ThemeData theme, Map<String, dynamic> student) {
    final String risk = student['risk'] as String? ?? "Low";
    final Color color = risk == "High"
        ? Colors.redAccent
        : risk == "Medium"
        ? Colors.orange
        : Colors.green;
    final IconData icon = risk == "High"
        ? Icons.warning_amber_rounded
        : risk == "Medium"
        ? Icons.info_outline
        : Icons.check_circle_outline;

    // Risk score: High=75-100, Medium=40-74, Low=0-39  (visual only)
    final int score = risk == "High"
        ? 85
        : risk == "Medium"
        ? 55
        : 25;

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
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.12),
                child: Text(
                  (student['name'] as String? ?? "?").isNotEmpty
                      ? (student['name'] as String)[0].toUpperCase()
                      : "?",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student['name'] ?? "—",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      "${student['dept'] ?? '—'}   •   ID ${student['rollId'] ?? '—'}",
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Risk badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 13, color: color),
                    const SizedBox(width: 4),
                    Text(risk,
                        style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Risk score",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text("$score / 100",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 8,
              backgroundColor: theme.dividerColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}