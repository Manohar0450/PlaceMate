import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'session_manager.dart';

/// Works for principal, coordinator and student.
/// - Principal & Coordinator: PUT /update-{role}/{_id}   with { password }
/// - Student               : PUT /update-student/{rollId} with { password }
///
/// The backend routes already accept a `password` field in the body.
class ChangePasswordPage extends StatefulWidget {
  final String userId;
  final String userRole; // "principal" | "coordinator" | "student"

  const ChangePasswordPage({
    super.key,
    required this.userId,
    required this.userRole,
  });

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;

  static const String _baseUrl =
      "https://placemate-backend-coral.vercel.app";

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── VALIDATION ────────────────────────────────────────────────────────────
  String? _validateNew(String value) {
    if (value.length < 8) return "Minimum 8 characters";
    if (!value.contains(RegExp(r'[A-Z]'))) return "Add at least 1 uppercase letter";
    if (!value.contains(RegExp(r'[a-z]'))) return "Add at least 1 lowercase letter";
    if (!value.contains(RegExp(r'[0-9]'))) return "Add at least 1 number";
    if (!value.contains(RegExp(r'[!@#\$&*~]')))
      return "Add at least 1 special char (!@#\$&*~)";
    return null;
  }

  // ── CHANGE PASSWORD ───────────────────────────────────────────────────────
  Future<void> _changePassword() async {
    final current = _currentCtrl.text;
    final newPass = _newCtrl.text;
    final confirm = _confirmCtrl.text;

    // Basic client-side checks
    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _snack("Please fill in all fields", Colors.orange);
      return;
    }
    if (newPass != confirm) {
      _snack("New passwords do not match", Colors.redAccent);
      return;
    }
    final err = _validateNew(newPass);
    if (err != null) {
      _snack(err, Colors.orange);
      return;
    }
    if (current == newPass) {
      _snack("New password must be different from current", Colors.orange);
      return;
    }

    // Verify current password locally against session data
    final saved = await SessionManager.getSavedUserData();
    if (saved == null) {
      _snack("Session expired. Please log in again.", Colors.redAccent);
      return;
    }
    if (saved['password'] != current) {
      _snack("Current password is incorrect", Colors.redAccent);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Build the correct endpoint
      final String idSegment = widget.userRole == "student"
          ? (saved['rollId'] ?? widget.userId)
          : widget.userId;

      final String endpoint =
          "$_baseUrl/update-${widget.userRole}/$idSegment";

      final response = await http.put(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"password": newPass}),
      );

      if (response.statusCode == 200) {
        // Update the local session so the in-memory password stays in sync
        final updatedUser = <String, dynamic>{...saved, 'password': newPass};
        await SessionManager.updateUserData(updatedUser);

        if (mounted) {
          _snack("Password changed successfully!", Colors.green);
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pop(context);
        }
      } else {
        final body = jsonDecode(response.body);
        _snack(body['error'] ?? "Update failed", Colors.redAccent);
      }
    } catch (e) {
      _snack("Connection error: ${e.toString()}", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Password must be 8+ chars with uppercase, lowercase, number and special character.",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Current ──────────────────────────────────────────────────
            _sectionLabel("Current Password"),
            _passwordField(
              controller: _currentCtrl,
              hint: "Enter current password",
              obscure: _obscureCurrent,
              onToggle: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 20),

            // ── New ───────────────────────────────────────────────────────
            _sectionLabel("New Password"),
            _passwordField(
              controller: _newCtrl,
              hint: "Enter new password",
              obscure: _obscureNew,
              onToggle: () =>
                  setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 20),

            // ── Confirm ───────────────────────────────────────────────────
            _sectionLabel("Confirm New Password"),
            _passwordField(
              controller: _confirmCtrl,
              hint: "Re-enter new password",
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 36),

            // ── Submit ────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _changePassword,
                child: _isSaving
                    ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                    : const Text("Update Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 14)),
  );

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: onToggle,
        ),
        border:
        OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}