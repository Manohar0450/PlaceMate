import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String userRole; // "principal" | "coordinator" | "student"

  const EditProfilePage({
    super.key,
    required this.userData,
    required this.userRole,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _infoController; // institution or dept
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.userData['name'] ?? '');
    _phoneController =
        TextEditingController(text: widget.userData['phone'] ?? '');
    _infoController = TextEditingController(
      text: widget.userRole == 'principal'
          ? (widget.userData['institution'] ?? '')
          : (widget.userData['dept'] ?? ''),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final info = _infoController.text.trim();

    if (name.isEmpty) {
      _showSnackBar("Name cannot be empty", Colors.orange);
      return;
    }

    setState(() => _isSaving = true);

    // Principal & coordinator use _id; student uses rollId
    final String idSegment = widget.userRole == 'student'
        ? (widget.userData['rollId'] ?? widget.userData['_id'] ?? '')
        : (widget.userData['_id'] ?? '');

    final String apiUrl =
        "https://placemate-backend-coral.vercel.app/update-${widget.userRole}/$idSegment";

    try {
      final Map<String, String> body = {
        "name": name,
        "phone": phone,
        if (widget.userRole == 'principal') "institution": info else "dept": info,
      };

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        // Server returns { message, principal } or { message, coordinator } or { message }
        final serverUser = (responseBody[widget.userRole] ??
            responseBody['student']) as Map<String, dynamic>?;

        // Merge: start with existing local data, apply server fields,
        // then guarantee phone/info are saved even if server omits them
        final merged = <String, dynamic>{
          ...widget.userData,
          if (serverUser != null) ...serverUser,
          'name': name,
          'phone': phone,
          if (widget.userRole == 'principal') 'institution': info else 'dept': info,
        };

        await SessionManager.updateUserData(merged);

        if (mounted) {
          _showSnackBar("Profile updated successfully!", Colors.green);
          Navigator.pop(context, true); // signal AccountInfoPage to reload
        }
      } else {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(err['error'] ?? "Update failed");
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Error: ${e.toString()}", Colors.redAccent);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final String infoLabel =
    widget.userRole == 'principal' ? "Institution Name" : "Department";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar preview ────────────────────────────────────────────
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Text(
                  (_nameController.text.isNotEmpty)
                      ? _nameController.text[0].toUpperCase()
                      : "?",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Fields ────────────────────────────────────────────────────
            _buildField(
              controller: _nameController,
              label: "Full Name",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _phoneController,
              label: "Phone Number",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _infoController,
              label: infoLabel,
              icon: Icons.school_outlined,
            ),
            const SizedBox(height: 40),

            // ── Save button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _updateProfile,
                icon: _isSaving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : const Icon(Icons.save_outlined),
                label:
                Text(_isSaving ? "Saving..." : "Save Changes"),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
      ),
    );
  }
}