import 'package:flutter/material.dart';

class PlacementListScreen extends StatefulWidget {
  const PlacementListScreen({super.key});

  @override
  State<PlacementListScreen> createState() => _PlacementListScreenState();
}

class _PlacementListScreenState extends State<PlacementListScreen> {
  final List<Map<String, String>> placements = [
    {"company": "MountBlue", "role": "Full Stack Developer", "lpa": "4.01 LPA", "stage": "Open"},
    {"company": "Stats", "role": "Data entry", "lpa": "3 LPA", "stage": "Screening"},
    {"company": "24/7ai", "role": "NON-Voice", "lpa": "3 LPA", "stage": "Screening"},
    {"company": "Itc", "role": "It consultant", "lpa": "4 LPA", "stage": "Screening"},


  ];

  void _addPlacement() {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final lpaCtrl = TextEditingController();
    String selectedStage = 'Open';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 32,
              bottom: MediaQuery.of(context).viewInsets.bottom + 32
          ),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32))
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  "Add Placement",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold) // BOLD
              ),
              const SizedBox(height: 24),
              _sheetInput("Company Name", nameCtrl, Icons.business),
              _sheetInput("Role", roleCtrl, Icons.work_outline),
              _sheetInput("LPA Package", lpaCtrl, Icons.payments_outlined),
              const Text(
                  "Current Stage",
                  style: TextStyle(fontWeight: FontWeight.bold) // BOLD
              ),
              DropdownButton<String>(
                value: selectedStage,
                isExpanded: true,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue), // BOLD
                items: ['Open', 'Screening', 'Interview']
                    .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)) // BOLD
                )).toList(),
                onChanged: (v) => setSheetState(() => selectedStage = v!),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      placements.insert(0, {
                        "company": nameCtrl.text,
                        "role": roleCtrl.text,
                        "lpa": "${lpaCtrl.text} LPA",
                        "stage": selectedStage,
                      });
                    });
                    Navigator.pop(context);
                  },
                  child: const Text(
                      "Add Posting",
                      style: TextStyle(fontWeight: FontWeight.bold) // BOLD
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int openCount = placements.where((p) => p['stage'] == 'Open').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryCard(theme, "Coordinator dashboard", "Placement pipeline",),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _countCard(theme, "Open", openCount.toString(), Icons.shopping_bag_outlined)),
              const SizedBox(width: 16),
              Expanded(child: _countCard(theme, "Shortlisted", "48", Icons.check_circle_outline)),
            ],
          ),
          const SizedBox(height: 24),
          _listContainer(theme),
        ],
      ),
    );
  }

  Widget _listContainer(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(
                    "Placement list",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18) // BOLD
                ),
                const Text(
                    "Latest postings and stage",
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold) // BOLD
                ),
              ]),
              ElevatedButton.icon(
                onPressed: _addPlacement,
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                    "Add",
                    style: TextStyle(fontWeight: FontWeight.bold) // BOLD
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...placements.map((p) => _companyTile(theme, p)),
        ],
      ),
    );
  }

  Widget _companyTile(ThemeData theme, Map<String, String> p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                p['company']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16) // BOLD
            ),
            Text(
                "${p['role']}   ${p['lpa']}",
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold) // BOLD
            ),
          ]),
          _badge(p['stage']!),
        ],
      ),
    );
  }

  Widget _badge(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold) // BOLD
    ),
  );

  Widget _countCard(ThemeData theme, String label, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold) // BOLD
          ),
          Row(
            children: [
              if (label == "Open")
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: Colors.green),
                      SizedBox(width: 4),
                      Text(
                          "Live",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold) // BOLD
                      ),
                    ],
                  ),
                ),
              Icon(icon, size: 16, color: Colors.grey),
            ],
          ),
        ]),
        const SizedBox(height: 8),
        Text(
            count,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold) // BOLD
        ),
      ]),
    );
  }

  Widget _summaryCard(ThemeData theme, String sub, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(28)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            sub,
            style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold) // BOLD
        ),
        Text(
            title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold) // BOLD
        ),
      ]),
    );
  }

  Widget _sheetInput(String label, TextEditingController ctrl, IconData icon) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13) // BOLD
      ),
      const SizedBox(height: 6),
      TextField(
          controller: ctrl,
          style: const TextStyle(fontWeight: FontWeight.bold), // BOLD USER INPUT
          decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20),
              hintText: "Enter $label",
              hintStyle: const TextStyle(fontWeight: FontWeight.normal)
          )
      ),
      const SizedBox(height: 16),
    ]);
  }
}