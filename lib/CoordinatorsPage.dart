import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CoordinatorsPage extends StatefulWidget {
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
      setState(() => isLoading = false);
    }
  }

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
          "createdBy": widget.currentPrincipalId,
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

  Future<void> _updateCoordinatorInBackend(String id, Map<String, String> data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update-coordinator/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        _fetchCoordinators();
        _showSnackBar("Coordinator updated successfully!", Colors.blue);
      } else {
        _showSnackBar("Update failed", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Connection failed", Colors.red);
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

  void _showCoordinatorSheet({dynamic coordinator}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CoordinatorFormSheet(
          coordinator: coordinator,
          onSave: (data) {
            if (coordinator == null) {
              _addCoordinatorToBackend(data);
            } else {
              _updateCoordinatorInBackend(coordinator['_id'], data);
            }
          },
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
          onPressed: () => _showCoordinatorSheet(),
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
            onPressed: () => _showCoordinatorSheet(coordinator: c),
            icon: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent),
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

class CoordinatorFormSheet extends StatefulWidget {
  final dynamic coordinator;
  final Function(Map<String, String>) onSave;

  const CoordinatorFormSheet({super.key, this.coordinator, required this.onSave});

  @override
  State<CoordinatorFormSheet> createState() => _CoordinatorFormSheetState();
}

class _CoordinatorFormSheetState extends State<CoordinatorFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _branch;
  late TextEditingController _pass;

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.coordinator?['name'] ?? "");
    _email = TextEditingController(text: widget.coordinator?['email'] ?? "");
    _branch = TextEditingController(text: widget.coordinator?['dept'] ?? "");
    _pass = TextEditingController(text: widget.coordinator?['password'] ?? "");
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _branch.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.coordinator != null;

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
              Text(
                isEditing ? "Edit Coordinator" : "Add Coordinator",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              _field("Name", _name, Icons.person, validator: (v) {
                if (v == null || v.isEmpty) return "Name required";
                if (v.trim().length < 4) return "Name too short (min 4)";
                return null;
              }),

              _field("Email Address", _email, Icons.email, validator: (v) {
                if (v == null || v.isEmpty) return "Email required";
                if (!v.contains('@')) return "Invalid email (missing @)";

                // Rule: 4 chars before @ and 4 chars after @
                List<String> parts = v.split('@');
                if (parts.length != 2 || parts[0].length < 4 || parts[1].length < 4) {
                  return "Need 4+ chars before and after @";
                }
                return null;
              }),

              _field("Department", _branch, Icons.apartment, validator: (v) {
                if (v == null || v.isEmpty) return "Department required";
                // Rule: Enough with 4 letters
                if (v.trim().length < 4) return "Department must be 4+ letters";
                return null;
              }),

              _field(
                "Password",
                _pass,
                Icons.lock,
                isPass: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Password required";
                  // Rule: 1 Upper, 1 Lower, 1 Digit, 1 Special
                  bool hasUpper = v.contains(RegExp(r'[A-Z]'));
                  bool hasLower = v.contains(RegExp(r'[a-z]'));
                  bool hasDigits = v.contains(RegExp(r'[0-9]'));
                  bool hasSpecial = v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

                  if (!hasUpper || !hasLower || !hasDigits || !hasSpecial) {
                    return "Need: 1 Upper, 1 Lower, 1 Digit, 1 Special";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isEditing ? "Update Account" : "Create Coordinator Account",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      widget.onSave({
        "name": _name.text.trim(),
        "email": _email.text.trim(),
        "dept": _branch.text.trim(),
        "password": _pass.text,
      });
      Navigator.pop(context);
    }
  }

  Widget _field(String label, TextEditingController controller, IconData icon,
      {bool isPass = false, Widget? suffixIcon, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPass,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: suffixIcon,
            hintText: "Enter $label",
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}