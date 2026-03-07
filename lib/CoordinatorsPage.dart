import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CoordinatorsPage extends StatefulWidget {
  // 1. ADDED: Receive the Principal's ID to filter data
  final String currentPrincipalId;

  const CoordinatorsPage({super.key, required this.currentPrincipalId});

  @override
  State<CoordinatorsPage> createState() => _CoordinatorsPageState();
}

class _CoordinatorsPageState extends State<CoordinatorsPage> {
  final String baseUrl = "https://placemate-backend-coral.vercel.app";

  List<dynamic> coordinators = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCoordinators();
  }

  // 2. UPDATED: URL now includes principalId for isolation
  Future<void> _fetchCoordinators() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/coordinators/${widget.currentPrincipalId}"),
      );

      if (response.statusCode == 200) {
        setState(() {
          coordinators = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar("Error loading coordinators", Colors.red);
    }
  }

  // 3. UPDATED: Added 'createdBy' to the body
  Future<void> _addCoordinatorToBackend(Map<String, String> newCoord) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add-coordinator"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": newCoord['name'],
          "email": newCoord['email'],
          "dept": newCoord['dept'],
          "password": newCoord['password'],
          "createdBy": widget.currentPrincipalId, // Link to current principal
        }),
      );

      if (response.statusCode == 201) {
        _fetchCoordinators();
        _showSnackBar("Coordinator created successfully!", Colors.green);
      } else {
        final error = jsonDecode(response.body);
        _showSnackBar(error['error'] ?? "Failed to create account", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Backend connection failed", Colors.red);
    }
  }

  Future<void> _deleteCoordinator(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/coordinator/$id"),
      );

      if (response.statusCode == 200) {
        _fetchCoordinators();
        _showSnackBar("Coordinator removed", Colors.blueGrey);
      }
    } catch (e) {
      _showSnackBar("Delete failed", Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddCoordinatorSheet(
          onAdd: (data) => _addCoordinatorToBackend(data),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchCoordinators,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildSearchBar(theme),
              const SizedBox(height: 24),
              if (coordinators.isEmpty)
                const Text(
                  "No coordinators found",
                  style: TextStyle(color: Colors.grey),
                ),
              ...coordinators.map(
                    (data) => _coordinatorCard(theme, data),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Coordinator creation & management",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              "Coordinators",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddSheet(context),
          icon: const Icon(Icons.person_add_alt_1, size: 18),
          label: const Text("Add"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _coordinatorCard(ThemeData theme, dynamic c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c['name'] ?? "No Name",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${c['dept']} • ${c['email']}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteCoordinator(c['_id']),
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search coordinators...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/* ---------------- ADD COORDINATOR SHEET ---------------- */

class AddCoordinatorSheet extends StatefulWidget {
  final Function(Map<String, String>) onAdd;

  const AddCoordinatorSheet({super.key, required this.onAdd});

  @override
  State<AddCoordinatorSheet> createState() => _AddCoordinatorSheetState();
}

class _AddCoordinatorSheetState extends State<AddCoordinatorSheet> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _branch = TextEditingController();
  final _pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add Coordinator",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _nameField(),
              _emailField(),
              _deptField(),
              _passwordField(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Create Coordinator Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onAdd({
        "name": _name.text.trim(),
        "email": _email.text.trim(),
        "dept": _branch.text.trim(),
        "password": _pass.text,
      });

      Navigator.pop(context);
    }
  }

  Widget _nameField() {
    return _field(
      "Name",
      _name,
      Icons.person,
      validator: (v) {
        if (v == null || v.isEmpty) return "Name required";
        if (v.length < 6) return "Minimum 6 characters";
        if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(v)) return "Only letters allowed";
        return null;
      },
    );
  }

  Widget _emailField() {
    return _field(
      "Email Address",
      _email,
      Icons.email,
      validator: (v) {
        if (v == null || v.isEmpty) return "Email required";
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return "Enter valid email";
        return null;
      },
    );
  }

  Widget _deptField() {
    return _field(
      "Department",
      _branch,
      Icons.apartment,
      validator: (v) {
        if (v == null || v.isEmpty) return "Department required";
        if (v.length < 3) return "Minimum 3 characters";
        return null;
      },
    );
  }

  Widget _passwordField() {
    return _field(
      "Password",
      _pass,
      Icons.lock,
      isPass: true,
      validator: (v) {
        if (v == null || v.isEmpty) return "Password required";
        if (v.length < 6) return "Minimum 6 characters";
        if (!RegExp(r'(?=.*[A-Z])').hasMatch(v)) return "Must contain uppercase letter";
        if (!RegExp(r'(?=.*[a-z])').hasMatch(v)) return "Must contain lowercase letter";
        if (!RegExp(r'(?=.*[0-9])').hasMatch(v)) return "Must contain number";
        if (!RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(v)) return "Must contain special character";
        return null;
      },
    );
  }

  Widget _field(
      String label,
      TextEditingController controller,
      IconData icon, {
        bool isPass = false,
        String? Function(String?)? validator,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPass,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            hintText: "Enter $label",
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}