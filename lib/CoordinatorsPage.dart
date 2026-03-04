import 'package:flutter/material.dart';

class CoordinatorsPage extends StatefulWidget {
  const CoordinatorsPage({super.key});

  @override
  State<CoordinatorsPage> createState() => _CoordinatorsPageState();
}

class _CoordinatorsPageState extends State<CoordinatorsPage> {
  // The dynamic list of coordinators
  final List<Map<String, String>> coordinators = [
    {"name": "Suresh", "dept": "Aiml", "email": "suresh@gmail.com", "status": "Active"},
    {"name": "Arjun Reddy", "dept": "Cse", "email": "arjun@gmail.com", "status": "Invited"},
    {"name": "Sailaja", "dept": "IOT", "email": "sailaja@gmail.com", "status": "Active"},
  ];

  // Logic to remove a coordinator from the list
  void _deleteCoordinator(int index) {
    setState(() {
      coordinators.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Coordinator removed"),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Logic to show the Add Coordinator sheet
  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCoordinatorSheet(
        onAdd: (newCoord) {
          setState(() {
            coordinators.insert(0, newCoord); // Adds to the top of the list
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Header Section
            _buildHeader(context),
            const SizedBox(height: 20),

            /// Search Bar
            _buildSearchBar(theme),
            const SizedBox(height: 24),

            /// Coordinator Cards
            ...coordinators.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, String> data = entry.value;
              return _coordinatorCard(theme, data, index);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Coordinator creation & management",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text("Coordinators",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              )),
        ]),
        ElevatedButton.icon(
          onPressed: () => _showAddSheet(context),
          icon: const Icon(Icons.person_add_alt_1, size: 18,),
          label: const Text("Add"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        )
      ],
    );
  }

  Widget _coordinatorCard(ThemeData theme, Map<String, String> c, int index) {
    bool isActive = c['status'] == "Active";

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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(width: 8),
                _statusBadge(c['status']!, isActive),
              ]),
              const SizedBox(height: 4),
              Text("${c['dept']}    ${c['email']}",
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ]),
          ),

          /// Activate Button
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 16),
            label: const Text("Activate"),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
            ),
          ),

          /// Delete (Trash) Button
          IconButton(
            onPressed: () => _deleteCoordinator(index),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, bool active) {
    final color = active ? const Color(0xFF6C9EFF) : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (active) Icon(Icons.check, size: 12, color: color),
        if (active) const SizedBox(width: 4),
        Text(label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search by name, dept, email",
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/* ------------------- Add Coordinator Sheet Widget ------------------- */

class AddCoordinatorSheet extends StatelessWidget {
  final Function(Map<String, String>) onAdd;
  AddCoordinatorSheet({super.key, required this.onAdd});

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _branch = TextEditingController();
  final _pass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Add Coordinator",
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
          const SizedBox(height: 24),
          _field("Name", _name, Icons.person_outline),
          _field("Email Address", _email, Icons.mail_outline),
          _field("Branch / Department", _branch, Icons.apartment),
          _field("Assign Password", _pass, Icons.lock_outline, isPass: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_name.text.isNotEmpty) {
                  onAdd({
                    "name": _name.text,
                    "dept": _branch.text,
                    "email": _email.text,
                    "status": "Invited",
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Create Coordinator Account",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon, {bool isPass = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
        obscureText: isPass,
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
    ]);
  }
}