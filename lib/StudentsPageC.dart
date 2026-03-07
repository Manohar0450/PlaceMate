import 'package:flutter/material.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/students/${widget.coordinatorId}"),
      );

      if (response.statusCode == 200) {
        setState(() {
          students = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar("Error fetching students", Colors.red);
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteStudent(String rollId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/student/$rollId"),
      );

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
        _showSnackBar("Student account created in DB", Colors.green);
      } else {
        final error = jsonDecode(response.body);
        _showSnackBar(error['error'] ?? "Failed to create", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Connection failed", Colors.red);
    }
  }

  Future<void> _updateRiskLevel(String rollId, String newRisk) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/student/risk"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "rollId": rollId,
          "newRisk": newRisk,
        }),
      );

      if (response.statusCode == 200) {
        _fetchStudents();
        _showSnackBar("Risk updated to $newRisk", Colors.blue);
      }
    } catch (e) {
      _showSnackBar("Failed to update risk", Colors.red);
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

  void _showAddStudentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddStudentSheet(
        onAdd: (studentData) => _addStudentToDB(studentData),
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
                              fontSize: 28, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _showAddStudentSheet,
                      icon: const Icon(Icons.add),
                      label: const Text("Add"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                TextField(
                  decoration: InputDecoration(
                    hintText: "Search by ID, name, dept",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 20),

                if (students.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text(
                        "No students found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                ...students
                    .map((student) => _buildStudentCard(theme, student))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(ThemeData theme, dynamic student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: theme.cardColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 5),
                Text("${student['dept']}  |  ID ${student['rollId']}",
                    style: const TextStyle(color: Colors.grey)),
                Text(student['email'],
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (String newRisk) =>
                _updateRiskLevel(student['rollId'], newRisk),
            itemBuilder: (context) => ["Low", "Medium", "High"]
                .map((level) =>
                PopupMenuItem(value: level, child: Text(level)))
                .toList(),
            child: _riskBadge(student['risk'] ?? "Low"),
          ),

          const SizedBox(width: 8),

          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDeletion(student),
          ),
        ],
      ),
    );
  }

  void _confirmDeletion(dynamic student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Student"),
        content: Text(
            "Are you sure you want to remove ${student['name']}? This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStudent(student['rollId']);
            },
            child:
            const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _riskBadge(String level) {
    Color color =
    level == 'High' ? Colors.red : level == 'Medium' ? Colors.orange : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(level,
          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}

class AddStudentSheet extends StatefulWidget {
  final Function(Map<String, String>) onAdd;
  final List<String> existingIds;

  const AddStudentSheet(
      {super.key, required this.onAdd, required this.existingIds});

  @override
  State<AddStudentSheet> createState() => _AddStudentSheetState();
}

class _AddStudentSheetState extends State<AddStudentSheet> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _roll = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _dept = TextEditingController(text: "CSE");

  String _risk = "Low";

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding:
      EdgeInsets.only(left: 24, right: 24, top: 32, bottom: bottomPadding + 32),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text("Add New Student",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

              const SizedBox(height: 20),

              _buildTextField("Full Name", _name, Icons.person_outline, isName: true),

              const SizedBox(height: 15),

              _buildTextField("Email Address", _email, Icons.email_outlined,
                  isEmail: true),

              const SizedBox(height: 15),

              _buildTextField("Roll Number / ID", _roll, Icons.badge_outlined,
                  isRoll: true),

              const SizedBox(height: 15),

              _buildTextField("Login Password", _password, Icons.lock_outline,
                  isPassword: true),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: _risk,
                decoration: const InputDecoration(
                    labelText: "Initial Risk Level",
                    border: OutlineInputBorder()),
                items: ["Low", "Medium", "High"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _risk = v!),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  child: const Text("Create Student Account",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onAdd({
                        "name": _name.text.trim(),
                        "email": _email.text.trim(),
                        "id": _roll.text.trim(),
                        "dept": _dept.text,
                        "risk": _risk,
                        "password": _password.text,
                      });

                      Navigator.pop(context);
                    }
                  },
                ),
              )
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
      }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType:
      isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "$label is required";
        }

        String v = value.trim();

        if (isName) {
          if (v.length < 6) return "Name must be at least 6 characters";
          if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(v)) {
            return "Only letters allowed";
          }
        }

        if (isEmail) {
          if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(v)) {
            return "Enter valid email";
          }
        }

        if (isRoll) {
          if (v.length < 4) return "Roll ID must be at least 4 characters";
          if (widget.existingIds.contains(v)) {
            return "ID already exists";
          }
        }

        if (isPassword) {
          if (v.length < 6) return "Password must be at least 6 characters";

          if (!RegExp(r'[A-Z]').hasMatch(v)) {
            return "Must contain uppercase letter";
          }

          if (!RegExp(r'[a-z]').hasMatch(v)) {
            return "Must contain lowercase letter";
          }

          if (!RegExp(r'[0-9]').hasMatch(v)) {
            return "Must contain a number";
          }

          if (!RegExp(r'[!@#\$&*~]').hasMatch(v)) {
            return "Must contain special character";
          }
        }

        return null;
      },
    );
  }
}