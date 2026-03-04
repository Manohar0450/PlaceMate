import 'package:flutter/material.dart';

class AIProcessingScreen extends StatefulWidget {
  const AIProcessingScreen({super.key});

  @override
  State<AIProcessingScreen> createState() => _AIProcessingScreenState();
}

class _AIProcessingScreenState extends State<AIProcessingScreen> {
  final _inputController = TextEditingController();
  String _output = "Output will appear here...";
  bool _isLoading = false;

  Future<void> _processWithGemini() async {
    setState(() => _isLoading = true);

    // --- PLACE YOUR GEMINI API CALL HERE ---
    // Example logic:
    // final response = await geminiService.processText(_inputController.text);
    // setState(() => _output = response);

    await Future.delayed(const Duration(seconds: 2)); // Mock delay
    setState(() {
      _output = "Placement Posting (AI-processed)\n\n• Company: (Extracted Name)\n• Role: Graduate Engineer Trainee\n• Deadline: Friday 6PM";
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(theme),
              const SizedBox(height: 24),
              _buildInputSection(theme),
              const SizedBox(height: 24),
              _buildOutputSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(28)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("AI processing", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          Text("Process a placement\nparagraph", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildInputSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Input", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ElevatedButton(
                onPressed: _isLoading ? null : _processWithGemini,
                child: _isLoading ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Process"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            maxLines: 5,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(hintText: "Paste raw text here...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Output", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Text(_output, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        ],
      ),
    );
  }
}