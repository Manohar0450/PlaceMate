import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';
import 'edit_profile_page.dart';

class AccountInfoPage extends StatefulWidget {
  final String userId;
  final String userRole; // "principal" | "coordinator" | "student"

  const AccountInfoPage({
    super.key,
    required this.userId,
    required this.userRole,
  });

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ── Load from session ────────────────────────────────────────────────────
  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    final saved = await SessionManager.getSavedUserData();
    setState(() {
      userData = saved;
      isLoading = false;
    });
  }

  // ── Navigate to EditProfilePage and refresh on return ───────────────────
  Future<void> _goToEditPage() async {
    if (userData == null) return;

    final didUpdate = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          userData: userData!,
          userRole: widget.userRole,
        ),
      ),
    );

    // ✅ Key fix: reload session data when returning from edit
    if (didUpdate == true) {
      await _loadUserData();
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    if (userData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Account Info")),
        body: const Center(
            child: Text("User data not found. Please log in again.")),
      );
    }

    final theme = Theme.of(context);

    final String infoLabel =
    widget.userRole == "principal" ? "Institution" : "Department";
    final String infoValue = widget.userRole == "principal"
        ? (userData!['institution'] ?? "Not set")
        : (userData!['dept'] ?? "Not set");

    final Map<String, Map<String, dynamic>> roleMeta = {
      'principal': {'label': 'Principal', 'color': Colors.blue},
      'coordinator': {'label': 'Coordinator', 'color': Colors.purple},
      'student': {'label': 'Student', 'color': Colors.teal},
    };
    final meta = roleMeta[widget.userRole] ??
        {'label': widget.userRole, 'color': Colors.grey};

    // Phone display
    final String phoneDisplay =
    (userData!['phone'] != null &&
        (userData!['phone'] as String).isNotEmpty)
        ? userData!['phone'] as String
        : "Tap edit to add";

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        actions: [
          isUpdating
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(strokeWidth: 2)),
          )
              : IconButton(
            onPressed: _goToEditPage,
            icon: const Icon(Icons.edit_outlined),
            tooltip: "Edit Profile",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Avatar + role badge ───────────────────────────────────────
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor:
                  theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    (userData!['name'] as String? ?? "?").isNotEmpty
                        ? (userData!['name'] as String)[0].toUpperCase()
                        : "?",
                    style: TextStyle(
                      fontSize: 34,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                    (meta['color'] as Color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: (meta['color'] as Color)
                            .withOpacity(0.4)),
                  ),
                  child: Text(
                    meta['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: meta['color'] as Color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              userData!['name'] ?? "",
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              userData!['email'] ?? "",
              style:
              const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 28),

            // ── Details card ──────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10)
                ],
              ),
              child: Column(
                children: [
                  _tile(Icons.person_outline, "Full Name",
                      userData!['name'] ?? "—"),
                  _divider(),
                  _tile(Icons.email_outlined, "Email",
                      userData!['email'] ?? "—"),
                  _divider(),
                  _tile(Icons.phone_outlined, "Phone", phoneDisplay),
                  _divider(),
                  _tile(Icons.school_outlined, infoLabel, infoValue),
                  _divider(),
                  _tile(Icons.badge_outlined, "System ID",
                      widget.userId),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Edit button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _goToEditPage,
                icon: const Icon(Icons.edit_outlined),
                label: const Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey, size: 20),
      title: Text(label,
          style: const TextStyle(fontSize: 11, color: Colors.grey)),
      subtitle: Text(value,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }

  Widget _divider() => Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: Colors.grey.withOpacity(0.1));
}