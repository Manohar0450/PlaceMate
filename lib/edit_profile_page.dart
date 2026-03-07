import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfilePage({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _instController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _phoneController = TextEditingController(text: widget.userData['phone']);
    _instController = TextEditingController(text: widget.userData['institution']);
  }

  Future<void> _updateProfile() async {
    setState(() => _isSaving = true);

    final String userId = widget.userData['_id']; // MongoDB ObjectID
    const String baseUrl = "https://placemate-backend-coral.vercel.app";

    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update-principal/$userId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text,
          "phone": _phoneController.text,
          "institution": _instController.text,
        }),
      );

      if (response.statusCode == 200) {
        final updatedData = jsonDecode(response.body)['principal'];

        // IMPORTANT: Update local SharedPreferences so the app reflects changes
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(updatedData));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Updated!")),
          );
          Navigator.pop(context, true); // Return 'true' to indicate data changed
        }
      }
    } catch (e) {
      print("Update Error: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name")),
            const SizedBox(height: 15),
            TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Phone Number")),
            const SizedBox(height: 15),
            TextField(controller: _instController, decoration: const InputDecoration(labelText: "Institution")),
            const SizedBox(height: 30),
            _isSaving
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}