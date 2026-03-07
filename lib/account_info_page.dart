import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AccountInfoPage extends StatefulWidget {
  final String userId;
  final String userRole; // "principal", "coordinator", or "student"

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
    _loadInitialData();
  }

  /// 1. Load data from local storage
  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('user_data');

    if (userJson != null) {
      setState(() {
        userData = jsonDecode(userJson);
        isLoading = false;
      });
    } else {
      // Fallback if login data wasn't saved correctly
      setState(() => isLoading = false);
    }
  }

  /// 2. Update Profile via Vercel API
  Future<void> _updateProfile(String name, String phone, String info) async {
    setState(() => isUpdating = true);

    // Dynamic URL based on role and ID
    final String apiUrl =
        "https://placemate-backend-coral.vercel.app/update-${widget.userRole}/${widget.userId}";

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name.trim(),
          "phone": phone.trim(),
          // Principal uses 'institution', others use 'dept'
          widget.userRole == "principal" ? "institution" : "dept": info.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Extract the user object from the response (principal, coordinator, or student)
        final updatedUser = responseData[widget.userRole] ?? responseData['student'];

        // SYNC: Update local storage so "Not Available" goes away
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(updatedUser));

        setState(() {
          userData = updatedUser;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully!")),
          );
        }
      } else {
        throw Exception("Failed to update");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  /// 3. Show Edit Modal
  void _showEditSheet() {
    final nameController = TextEditingController(text: userData?['name'] ?? "");
    final phoneController = TextEditingController(text: userData?['phone'] ?? "");

    // Handle the different keys for the third field
    String extraData = (widget.userRole == "principal")
        ? (userData?['institution'] ?? "")
        : (userData?['dept'] ?? "");
    final infoController = TextEditingController(text: extraData);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Update Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Full Name")),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone Number")),
            TextField(
              controller: infoController,
              decoration: InputDecoration(
                labelText: widget.userRole == "principal" ? "Institution Name" : "Department",
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateProfile(nameController.text, phoneController.text, infoController.text);
                },
                child: const Text("Save Changes"),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (userData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Account Info")),
        body: const Center(child: Text("User data not found. Please log in again.")),
      );
    }

    final theme = Theme.of(context);
    final String infoLabel = widget.userRole == "principal" ? "Institution" : "Department";
    final String infoValue = (widget.userRole == "principal")
        ? (userData!['institution'] ?? "None")
        : (userData!['dept'] ?? "None");

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            onPressed: isUpdating ? null : _showEditSheet,
            icon: isUpdating
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.edit),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 45,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                userData!['name'][0].toUpperCase(),
                style: TextStyle(fontSize: 30, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),

            // Profile Card
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _profileTile(Icons.person_outline, "Full Name", userData!['name']),
                  _profileTile(Icons.email_outlined, "Email Address", userData!['email']),
                  _profileTile(Icons.phone_outlined, "Phone", userData!['phone'] ?? "Add Phone"),
                  _profileTile(Icons.school_outlined, infoLabel, infoValue),
                  _profileTile(Icons.key_outlined, "System ID", widget.userId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}