import 'package:flutter/material.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  // Initial list of students from your screenshots
  final List<Map<String, String>> students = [
    {"name": "Seshu", "dept": "AIML", "id": "4226", "risk": "Medium"},
    {"name": "Jithendra", "dept": "CSE", "id": "4211", "risk": "High"},
    {"name": "Mithun", "dept": "Aiml", "id": "4210", "risk": "Low"},
    {"name": "Manohar", "dept": "Mech", "id": "4245", "risk": "High"},

  ];

  void _deleteStudent(int index) {
    setState(() => students.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Student record deleted", style: TextStyle(fontWeight: FontWeight.bold))),
    );
  }

  void _showAddStudentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddStudentSheet(
        onAdd: (newStudent) => setState(() => students.insert(0, newStudent)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Student creation & management",
                          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text("Students", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddStudentSheet,
                    icon: const Icon(Icons.add),
                    label: const Text("Add", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text("Includes risk monitoring at a glance.",
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Search Bar
              TextField(
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: "Search by ID, name, dept",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),

              // Student List
              ...students.asMap().entries.map((entry) => _buildStudentCard(theme, entry.value, entry.key)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(ThemeData theme, Map<String, String> student, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(28)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student['name']!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 4),
                Text("${student['dept']}    ID ${student['id']}",
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _riskBadge(student['risk']!),
          IconButton(
            onPressed: () => _deleteStudent(index),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          )
        ],
      ),
    );
  }

  Widget _riskBadge(String level) {
    Color color = level == 'High' ? Colors.redAccent : (level == 'Medium' ? Colors.blueAccent : Colors.greenAccent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(level, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }
}
class AddStudentSheet extends StatefulWidget {
  final Function(Map<String, String>) onAdd;
  const AddStudentSheet({super.key, required this.onAdd});

  @override
  State<AddStudentSheet> createState() => _AddStudentSheetState();
}

class _AddStudentSheetState extends State<AddStudentSheet> {
  final _name = TextEditingController();
  final _roll = TextEditingController();
  String _risk = 'Low';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 32, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Add New Student", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          _inputLabel("Full Name"),
          _textField(_name, "e.g. Aditi Sharma", Icons.person_outline),
          const SizedBox(height: 16),
          _inputLabel("Roll Number / ID"),
          _textField(_roll, "e.g. S-2101", Icons.badge_outlined),
          const SizedBox(height: 16),
          _inputLabel("Initial Risk Level"),
          DropdownButtonFormField<String>(
            value: _risk,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            decoration: InputDecoration(filled: true, fillColor: Colors.grey.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
            items: ['Low', 'Medium', 'High'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            onChanged: (v) => setState(() => _risk = v!),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                widget.onAdd({"name": _name.text, "id": _roll.text, "dept": "CSE", "risk": _risk, "password": "placemate"});
                Navigator.pop(context);
              },
              child: const Text("Create Student Account", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)));
  Widget _textField(TextEditingController c, String h, IconData i) => TextField(controller: c, style: const TextStyle(fontWeight: FontWeight.bold), decoration: InputDecoration(prefixIcon: Icon(i), hintText: h, filled: true, fillColor: Colors.grey.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)));
}