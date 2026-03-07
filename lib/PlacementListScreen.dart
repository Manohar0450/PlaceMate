import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacementListScreen extends StatefulWidget {
  final String coordinatorId;

  const PlacementListScreen({super.key, required this.coordinatorId});

  @override
  State<PlacementListScreen> createState() => _PlacementListScreenState();
}

class _PlacementListScreenState extends State<PlacementListScreen> {
  final String baseUrl = "https://placemate-backend-coral.vercel.app";
  List<dynamic> placements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlacements();
  }

  // --- API CALLS ---

  Future<void> _fetchPlacements() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/all-placements"));
      if (response.statusCode == 200) {
        setState(() {
          placements = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar("Could not sync with cloud", Colors.red);
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveToDatabase(Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add-placement"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "company": data['company'],
          "role": data['role'],
          "lpa": data['lpa'],
          "stage": data['stage'],
          "createdBy": widget.coordinatorId,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar("Posting saved!", Colors.green);
        _fetchPlacements();
      }
    } catch (e) {
      _showSnackBar("Database connection failed", Colors.red);
    }
  }

  Future<void> _updateDatabase(String id, Map<String, String> data) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update-placement/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        _showSnackBar("Placement updated!", Colors.blue);
        _fetchPlacements();
      }
    } catch (e) {
      _showSnackBar("Update failed", Colors.red);
    }
  }

  Future<void> _deletePlacement(String id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/delete-placement/$id"));
      if (response.statusCode == 200) {
        _showSnackBar("Record deleted", Colors.orange);
        _fetchPlacements();
      }
    } catch (e) {
      _showSnackBar("Delete failed", Colors.red);
    }
  }

  // --- UI LOGIC ---

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  void _confirmDelete(String id, String company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Posting"),
        content: Text("Are you sure you want to delete $company?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePlacement(id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openPlacementSheet({dynamic existingData}) {
    final bool isEditing = existingData != null;
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: isEditing ? existingData['company'] : "");
    final roleCtrl = TextEditingController(text: isEditing ? existingData['role'] : "");

    // Logic to strip " LPA" so the user only sees the number in the input
    String lpaInitial = "";
    if (isEditing && existingData['lpa'] != null) {
      lpaInitial = existingData['lpa'].toString().replaceAll(" LPA", "");
    }
    final lpaCtrl = TextEditingController(text: lpaInitial);

    String selectedStage = isEditing ? existingData['stage'] : 'Open';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 32,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEditing ? "Edit Placement" : "Add Placement",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _sheetInput("Company Name", nameCtrl, Icons.business, (v) => (v == null || v.isEmpty) ? "Required" : null),
                  _sheetInput("Role", roleCtrl, Icons.work_outline, (v) => (v == null || v.isEmpty) ? "Required" : null),
                  _sheetInput("LPA Package", lpaCtrl, Icons.payments_outlined, (v) => (v == null || v.isEmpty) ? "Required" : null, keyboardType: TextInputType.number),
                  const Text("Current Stage", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedStage,
                        isExpanded: true,
                        items: ['Open', 'Screening', 'Interview'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setSheetState(() => selectedStage = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final data = {
                            "company": nameCtrl.text.trim(),
                            "role": roleCtrl.text.trim(),
                            "lpa": "${lpaCtrl.text} LPA",
                            "stage": selectedStage,
                          };
                          if (isEditing) {
                            _updateDatabase(existingData['_id'], data);
                          } else {
                            _saveToDatabase(data);
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Text(isEditing ? "Update Posting" : "Add Posting",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int openCount = placements.where((p) => p['stage'] == 'Open').length;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openPlacementSheet(),
        label: const Text("New Placement"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchPlacements,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryCard(theme, "Coordinator dashboard", "Placement pipeline"),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _countCard(theme, "Open", openCount.toString(), Icons.shopping_bag_outlined, Colors.orange)),
                  const SizedBox(width: 16),
                  Expanded(child: _countCard(theme, "Total", placements.length.toString(), Icons.list_alt, Colors.blue)),
                ],
              ),
              const SizedBox(height: 24),
              _listContainer(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listContainer(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Placement list", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("Latest postings and stage", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (placements.isEmpty)
            const Padding(padding: EdgeInsets.all(40), child: Text("No placements found.", style: TextStyle(color: Colors.grey))),
          ...placements.map((p) => _companyTile(theme, p)),
        ],
      ),
    );
  }

  Widget _companyTile(ThemeData theme, dynamic p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 4),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['company'] ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${p['role']} • ${p['lpa']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          _badge(p['stage'] ?? "Open"),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (value) {
              if (value == 'edit') _openPlacementSheet(existingData: p);
              if (value == 'delete') _confirmDelete(p['_id'], p['company']);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text("Edit")])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
      ),
    );
  }

  // --- HELPER COMPONENTS ---

  Widget _badge(String label) {
    Color color = Colors.blue;
    if (label == 'Screening') color = Colors.orange;
    if (label == 'Interview') color = Colors.purple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _countCard(ThemeData theme, String label, String count, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))]
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Icon(icon, size: 16, color: color)]),
        const SizedBox(height: 8),
        Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _summaryCard(ThemeData theme, String sub, String title) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade400]),
        borderRadius: BorderRadius.circular(28)
    ),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.8))),
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white))
        ]
    ),
  );

  Widget _sheetInput(String label, TextEditingController ctrl, IconData icon, String? Function(String?) validator, {TextInputType keyboardType = TextInputType.text}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      TextFormField(
          controller: ctrl,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            hintText: "Enter $label",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          )
      ),
      const SizedBox(height: 16),
    ],
  );
}