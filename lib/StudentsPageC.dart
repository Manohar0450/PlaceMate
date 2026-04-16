import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentsPage extends StatefulWidget {
  final String coordinatorId;

  const StudentsPage({super.key, required this.coordinatorId});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final String baseUrl = "https://placemate-backend-coral.vercel.app";

  List<dynamic> students = [];
  List<dynamic> filtered = [];
  bool isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      filtered = q.isEmpty
          ? students
          : students
          .where((s) =>
      (s['name'] ?? '').toLowerCase().contains(q) ||
          (s['rollId'] ?? '').toLowerCase().contains(q) ||
          (s['dept'] ?? '').toLowerCase().contains(q))
          .toList();
    });
  }

  // ── FETCH: just load students as-is from backend, no auto risk overwrite ──
  Future<void> _fetchStudents() async {
    setState(() => isLoading = true);
    try {
      final res =
      await http.get(Uri.parse("$baseUrl/students/${widget.coordinatorId}"));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          students = data;
          filtered = data;
          isLoading = false;
        });
      } else {
        _showSnackBar("Failed to load students", Colors.red);
        setState(() => isLoading = false);
      }
    } catch (e) {
      _showSnackBar("Error fetching students", Colors.red);
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteStudent(String rollId) async {
    try {
      final response =
      await http.delete(Uri.parse("$baseUrl/student/$rollId"));
      if (response.statusCode == 200) {
        _fetchStudents();
        _showSnackBar("Student deleted successfully", Colors.blueGrey);
      } else {
        _showSnackBar("Failed to delete student", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Connection error", Colors.red);
    }
  }

  Future<void> _addStudentToDB(Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add-student"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": data['name'],
          "email": data['email'],
          "dept": data['dept'],
          "rollId": data['id'],
          "risk": data['risk'],
          "password": data['password'],
          "createdBy": widget.coordinatorId,
        }),
      );

      if (response.statusCode == 201) {
        _fetchStudents();
        _showSnackBar("Student account created", Colors.green);
      } else {
        final error = jsonDecode(response.body);
        _showSnackBar(error['error'] ?? "Failed to create", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Connection failed", Colors.red);
    }
  }

  Future<void> _updateStudentInDB(Map<String, String> data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update-student/${data['id']}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": data['name'],
          "phone": data['phone'],
          "dept": data['dept'],
        }),
      );
      if (response.statusCode == 200) {
        _fetchStudents();
        _showSnackBar("Student updated successfully", Colors.green);
      } else {
        _showSnackBar("Failed to update student", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Connection error", Colors.red);
    }
  }

  // ── MANUAL RISK UPDATE — coordinator explicitly chose this level ──────────
  Future<void> _updateRiskLevel(String rollId, String newRisk) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/student/risk"),
        headers: {"Content-Type": "application/json"},
        // Send manualOverride: true so backend (optionally) can flag it
        body: jsonEncode({
          "rollId": rollId,
          "newRisk": newRisk,
          "manualOverride": true,
        }),
      );
      if (response.statusCode == 200) {
        // Update locally so UI reflects immediately without full re-fetch
        setState(() {
          for (var s in students) {
            if (s['rollId'] == rollId) {
              s['risk'] = newRisk;
              break;
            }
          }
          // Re-apply search filter
          final q = _searchController.text.toLowerCase();
          filtered = q.isEmpty
              ? students
              : students
              .where((s) =>
          (s['name'] ?? '').toLowerCase().contains(q) ||
              (s['rollId'] ?? '').toLowerCase().contains(q) ||
              (s['dept'] ?? '').toLowerCase().contains(q))
              .toList();
        });
        _showSnackBar("Risk updated to $newRisk", Colors.blue);
      } else {
        _showSnackBar("Failed to update risk", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Failed to update risk", Colors.red);
    }
  }

  void _openStudentDetail(Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentDetailSheet(
        student: student,
        baseUrl: baseUrl,
        // When detail sheet auto-computes risk it calls back here so the
        // list card updates — but we DO NOT override a manual change.
        onRiskChanged: (String rollId, String newRisk) {
          setState(() {
            for (var s in students) {
              if (s['rollId'] == rollId) {
                s['risk'] = newRisk;
                break;
              }
            }
            final q = _searchController.text.toLowerCase();
            filtered = q.isEmpty
                ? students
                : students
                .where((s) =>
            (s['name'] ?? '').toLowerCase().contains(q) ||
                (s['rollId'] ?? '').toLowerCase().contains(q) ||
                (s['dept'] ?? '').toLowerCase().contains(q))
                .toList();
          });
        },
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showStudentForm({Map<String, dynamic>? student}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StudentFormSheet(
        student: student,
        onSave: (studentData) {
          if (student == null) {
            _addStudentToDB(studentData);
          } else {
            _updateStudentInDB(studentData);
          }
        },
        existingIds: students.map((s) => s['rollId'].toString()).toList(),
      ),
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
          onRefresh: _fetchStudents,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Student creation & management",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Students",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showStudentForm(),
                      icon: const Icon(Icons.add),
                      label: const Text("Add"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search by ID, name, dept",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (filtered.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text("No students found",
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),

                ...filtered
                    .map((student) => _buildStudentCard(theme, student)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(ThemeData theme, dynamic student) {
    return GestureDetector(
      onTap: () => _openStudentDetail(Map<String, dynamic>.from(student)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
              child: Text(
                (student['name'] ?? 'S')[0].toUpperCase(),
                style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'] ?? "Unknown",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${student['rollId'] ?? ''} • ${student['dept'] ?? ''}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            _riskBadge(student['risk'] ?? 'Low'),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              onSelected: (value) {
                if (value == 'edit') _showStudentForm(student: student);
                if (value == 'risk') _showRiskDialog(student);
                if (value == 'delete') _showDeleteDialog(student);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text("Edit")),
                PopupMenuItem(value: 'risk', child: Text("Change Risk")),
                PopupMenuItem(
                    value: 'delete',
                    child:
                    Text("Delete", style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRiskDialog(dynamic student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Change Risk — ${student['name']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ["Low", "Medium", "High"].map((level) {
            return ListTile(
              title: Text(level),
              onTap: () {
                Navigator.pop(context);
                _updateRiskLevel(student['rollId'], level);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteDialog(dynamic student) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text(
            "Remove ${student['name']} (${student['rollId']}) permanently?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStudent(student['rollId']);
            },
            child: const Text("Delete",
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _riskBadge(String level) {
    Color color = level == 'High'
        ? Colors.red
        : level == 'Medium'
        ? Colors.orange
        : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(level,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STUDENT DETAIL SHEET
// ─────────────────────────────────────────────────────────────
class StudentDetailSheet extends StatefulWidget {
  final Map<String, dynamic> student;
  final String baseUrl;

  /// Called when auto-computed risk differs from stored risk.
  /// Passes (rollId, newRisk) so the parent can update locally.
  final void Function(String rollId, String newRisk)? onRiskChanged;

  const StudentDetailSheet({
    super.key,
    required this.student,
    required this.baseUrl,
    this.onRiskChanged,
  });

  @override
  State<StudentDetailSheet> createState() => _StudentDetailSheetState();
}

class _StudentDetailSheetState extends State<StudentDetailSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool isLoading = true;
  List<dynamic> appliedJobs = [];
  List<dynamic> notAppliedJobs = [];

  // Local copy so the badge in this sheet also updates
  late String _currentRisk;

  @override
  void initState() {
    super.initState();
    _currentRisk = widget.student['risk'] ?? 'Low';
    _tab = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  String _appCompany(Map app) =>
      (app['company'] ?? app['companyName'] ?? app['Company'] ?? app['job_company'] ?? '')
          .toString()
          .toLowerCase()
          .trim();

  String _placementCompany(Map p) =>
      (p['company'] ?? p['companyName'] ?? p['Company'] ?? '')
          .toString()
          .toLowerCase()
          .trim();

  String _appRole(Map app) =>
      (app['role'] ?? app['jobRole'] ?? app['position'] ?? app['Role'] ?? '')
          .toString()
          .toLowerCase()
          .trim();

  String _placementRole(Map p) =>
      (p['role'] ?? p['jobRole'] ?? p['position'] ?? p['Role'] ?? '')
          .toString()
          .toLowerCase()
          .trim();

  Future<void> _loadData() async {
    try {
      final appRes = await http.get(Uri.parse(
          "${widget.baseUrl}/my-applications/${widget.student['rollId']}"));
      final allRes =
      await http.get(Uri.parse("${widget.baseUrl}/all-placements"));

      List applications = [];
      List allPlacements = [];

      if (appRes.statusCode == 200) applications = jsonDecode(appRes.body);
      if (allRes.statusCode == 200) allPlacements = jsonDecode(allRes.body);

      final List<dynamic> applied = [];
      final List<dynamic> notApplied = [];

      for (final placement in allPlacements) {
        final pCompany = _placementCompany(placement);
        final pRole = _placementRole(placement);
        final pId = (placement['_id'] ?? '').toString();

        Map? matchingApp;

        for (final app in applications) {
          final appMap = app as Map;
          final appPId =
          (appMap['placementId'] ?? appMap['placement_id'] ?? '').toString();
          if (pId.isNotEmpty && appPId.isNotEmpty && appPId == pId) {
            matchingApp = appMap;
            break;
          }
          final aC = _appCompany(appMap);
          if (pCompany.isNotEmpty && aC.isNotEmpty && aC == pCompany) {
            matchingApp = appMap;
            break;
          }
          final aR = _appRole(appMap);
          if (pCompany.isNotEmpty &&
              aC == pCompany &&
              pRole.isNotEmpty &&
              aR == pRole) {
            matchingApp = appMap;
            break;
          }
        }

        if (matchingApp != null) {
          final status = (matchingApp['status'] ??
              matchingApp['appStatus'] ??
              matchingApp['applicationStatus'] ??
              'Pending')
              .toString();
          applied.add({...placement, 'appStatus': status});
        } else {
          notApplied.add(placement);
        }
      }

      // ── Auto-compute risk from application data ───────────────────────
      final int notAppliedCount = notApplied.length;
      String computedRisk;
      if (notAppliedCount > 3) {
        computedRisk = 'High';
      } else if (notAppliedCount >= 2) {
        computedRisk = 'Medium';
      } else {
        computedRisk = 'Low';
      }

      // Only sync & notify parent if computed risk differs from what's stored.
      // This respects any manual override the coordinator may have set.
      final storedRisk = widget.student['risk'] ?? 'Low';
      if (computedRisk != storedRisk) {
        await http.patch(
          Uri.parse("${widget.baseUrl}/student/risk"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "rollId": widget.student['rollId'],
            "newRisk": computedRisk,
          }),
        );
        // Update local state for badge in this sheet
        if (mounted) setState(() => _currentRisk = computedRisk);
        // Tell parent list to update the card badge
        widget.onRiskChanged?.call(
            widget.student['rollId'] as String, computedRisk);
      }

      if (mounted) {
        setState(() {
          appliedJobs = applied;
          notAppliedJobs = notApplied;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("=== _loadData ERROR: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final student = widget.student;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Student header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                  child: Text(
                    (student['name'] ?? 'S')[0].toUpperCase(),
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'] ?? "Unknown",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${student['rollId'] ?? ''} • ${student['dept'] ?? ''}",
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _riskBadge(_currentRisk),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Summary chips
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _summaryChip("${appliedJobs.length} Applied", Colors.blue),
                  const SizedBox(width: 10),
                  _summaryChip(
                      "${notAppliedJobs.length} Not Applied", Colors.grey),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Tabs
          TabBar(
            controller: _tab,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: theme.colorScheme.primary,
            tabs: [
              Tab(
                  text:
                  "Applied (${isLoading ? '...' : appliedJobs.length})"),
              Tab(
                  text:
                  "Not Applied (${isLoading ? '...' : notAppliedJobs.length})"),
            ],
          ),

          // Tab content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tab,
              children: [
                _jobList(appliedJobs, isApplied: true, theme: theme),
                _jobList(notAppliedJobs,
                    isApplied: false, theme: theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobList(List jobs,
      {required bool isApplied, required ThemeData theme}) {
    if (jobs.isEmpty) {
      return Center(
        child: Text(
          isApplied ? "No applications yet" : "Applied to all jobs!",
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (_, i) {
        final job = jobs[i];
        final status = job['appStatus'] ?? job['stage'] ?? '';
        final statusColor = _statusColor(status);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isApplied
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isApplied
                      ? Icons.check_circle_outline
                      : Icons.radio_button_unchecked,
                  color: isApplied ? Colors.blue : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['company'] ?? "Company",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      "${job['role'] ?? ''} • ${job['lpa'] ?? ''}",
                      style:
                      const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isApplied && status.isNotEmpty)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              if (!isApplied)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    job['stage'] ?? "Open",
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return Colors.green;
      case 'offered':
        return Colors.purple;
      case 'attended':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _riskBadge(String level) {
    Color color = level == 'High'
        ? Colors.red
        : level == 'Medium'
        ? Colors.orange
        : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(level,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _summaryChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STUDENT FORM SHEET
// ─────────────────────────────────────────────────────────────
class StudentFormSheet extends StatefulWidget {
  final Map<String, dynamic>? student;
  final Function(Map<String, String>) onSave;
  final List<String> existingIds;

  const StudentFormSheet({
    super.key,
    this.student,
    required this.onSave,
    required this.existingIds,
  });

  @override
  State<StudentFormSheet> createState() => _StudentFormSheetState();
}

class _StudentFormSheetState extends State<StudentFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _roll;
  late TextEditingController _password;
  late TextEditingController _dept;
  late TextEditingController _phone;

  String _risk = "Low";
  bool _obscurePassword = true;
  bool get isEditMode => widget.student != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.student?['name'] ?? "");
    _email = TextEditingController(text: widget.student?['email'] ?? "");
    _roll = TextEditingController(text: widget.student?['rollId'] ?? "");
    _password = TextEditingController();
    _dept = TextEditingController(text: widget.student?['dept'] ?? "CSE");
    _phone = TextEditingController(text: widget.student?['phone'] ?? "");
    _risk = widget.student?['risk'] ?? "Low";
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
          left: 24, right: 24, top: 32, bottom: bottomPadding + 32),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                isEditMode ? "Update Student" : "Add New Student",
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 20),
              _buildTextField("Full Name", _name, Icons.person_outline,
                  isName: true),
              const SizedBox(height: 15),
              if (!isEditMode) ...[
                _buildTextField(
                    "Email Address", _email, Icons.email_outlined,
                    isEmail: true),
                const SizedBox(height: 15),
              ],
              _buildTextField(
                  "Roll Number / ID", _roll, Icons.badge_outlined,
                  isRoll: true, isEnabled: !isEditMode),
              const SizedBox(height: 15),
              _buildTextField("Phone Number", _phone, Icons.phone,
                  isPhone: true),
              const SizedBox(height: 15),
              if (!isEditMode) ...[
                _buildTextField(
                    "Login Password", _password, Icons.lock_outline,
                    isPassword: true),
                const SizedBox(height: 15),
              ],
              DropdownButtonFormField<String>(
                value: _risk,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: "Risk Level",
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder()),
                items: ["Low", "Medium", "High"]
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _risk = v!),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  child: Text(
                    isEditMode ? "Save Changes" : "Create Account",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSave({
                        "name": _name.text.trim(),
                        "email": _email.text.trim(),
                        "id": _roll.text.trim(),
                        "dept": _dept.text,
                        "risk": _risk,
                        "password": _password.text,
                        "phone": _phone.text.trim(),
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData icon, {
        bool isPassword = false,
        bool isEmail = false,
        bool isRoll = false,
        bool isName = false,
        bool isPhone = false,
        bool isEnabled = true,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      enabled: isEnabled,
      style: const TextStyle(color: Colors.white),
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
          ? TextInputType.number
          : TextInputType.text,
      maxLength: isPhone ? 10 : null,
      inputFormatters:
      isPhone ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        counterText: "",
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off
                : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        )
            : null,
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        filled: !isEnabled,
        fillColor: isEnabled ? null : Colors.grey.withOpacity(0.1),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          if (isPassword && isEditMode) return null;
          return "$label is required";
        }
        String v = value.trim();
        if (isName && v.length < 4) return "Name too short";
        if (isPhone && v.length != 10) return "Phone must be exactly 10 digits";
        if (isEmail && !isEditMode) {
          if (!v.contains('@')) return "Invalid email (missing @)";
          List<String> parts = v.split('@');
          if (parts.length != 2 ||
              parts[0].length < 4 ||
              parts[1].length < 4) {
            return "Need 4+ chars before and after @";
          }
        }
        if (isPassword && !isEditMode) {
          bool hasUppercase = v.contains(RegExp(r'[A-Z]'));
          bool hasLowercase = v.contains(RegExp(r'[a-z]'));
          bool hasDigits = v.contains(RegExp(r'[0-9]'));
          bool hasSpecial = v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
          if (!hasUppercase || !hasLowercase || !hasDigits || !hasSpecial) {
            return "Password needs: 1 Upper, 1 Lower, 1 Digit, 1 Special";
          }
        }
        if (isRoll && !isEditMode && widget.existingIds.contains(v)) {
          return "ID already exists";
        }
        return null;
      },
    );
  }
}