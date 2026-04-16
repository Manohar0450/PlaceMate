import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AIProcessingScreen extends StatefulWidget {
  final String coordinatorId;
  const AIProcessingScreen({super.key, required this.coordinatorId});

  @override
  State<AIProcessingScreen> createState() => _AIProcessingScreenState();
}

class _AIProcessingScreenState extends State<AIProcessingScreen> {
  final _inputController = TextEditingController();
  String _output = "Output will appear here...";
  bool _isLoading = false;
  bool _isPostEnabled = false;

  final String _apiKey = "AIzaSyDmomiUFSaws7LpulD2_Ymg5OcnoSc-lXU";
  final String _baseUrl = "https://placemate-backend-coral.vercel.app";

  Future<void> _processWithGemini() async {
    if (_inputController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _isPostEnabled = false;
      _output = "Coordinator AI is analyzing...";
    });

    try {
      const String model = 'gemini-2.5-flash';
      final Uri url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_apiKey');

      final Map<String, dynamic> requestBody = {
        "contents": [{
          "parts": [{
            "text": "System Instructions: You are a Placement Coordinator AI. "
                "Extract the following details from the input text and format it EXACTLY like this: "
                "Placement Posting (AI-processed)\n\n"
                "• Company: (Extracted Name)\n"
                "• Role: (Extracted Role)\n"
                "• Package/CTC: (Extracted Salary/Package details)\n"
                "• Deadline: (Extracted Date/Time)\n\n"
                "Rules:\n"
                "- If a field is missing, write 'Not Specified'.\n"
                "Input text: ${_inputController.text}"
          }]
        }],
        "generationConfig": {"temperature": 0.1, "maxOutputTokens": 350}
      };

      final client = HttpClient();
      final request = await client.postUrl(url);
      request.headers.set('Content-Type', 'application/json');
      request.add(utf8.encode(json.encode(requestBody)));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200) {
        final String aiText = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _output = aiText.trim();
          _isPostEnabled = true;
        });
      } else {
        setState(() => _output = "Error: ${jsonResponse['error']['message']}");
      }
    } catch (e) {
      setState(() => _output = "Connection Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _postToCloud() async {
    // 1. Parse the AI output lines locally first
    final lines = _output.split('\n');

    String findValue(String key) => lines
        .firstWhere((l) => l.contains(key), orElse: () => "$key Not Specified")
        .split(key)
        .last
        .trim();

    String company = findValue("• Company:");
    String role = findValue("• Role:");
    String lpa = findValue("• Package/CTC:");

    // 2. VALIDATION: Prevent posting if critical info is "Not Specified"
    if (company.toLowerCase().contains("not specified") ||
        role.toLowerCase().contains("not specified")) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(" AI could not identify Company or Role so please provide them."),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return; // Exit function without hitting the database
    }

    // 3. Proceed with network call if data is valid
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/add-placement"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "company": company,
          "role": role,
          "lpa": lpa,
          "stage": "Open",
          "createdBy": widget.coordinatorId,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Posted successfully to Dashboard!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            )
        );

        // Reset state so the user can process the next one (No Navigator.pop)
        setState(() {
          _inputController.clear();
          _output = "Output will appear here...";
          _isPostEnabled = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post Failed"), backgroundColor: Colors.red)
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _isPostEnabled && !_isLoading ? _postToCloud : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isLoading && _isPostEnabled
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("Post to Placement List", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
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

  Widget _buildHeader(ThemeData theme) => Container(
    width: double.infinity, padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(28)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      Text("AI processing", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      Text("Process a placement\nparagraph", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
    ]),
  );

  Widget _buildInputSection(ThemeData theme) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(28)),
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("Input", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        Row(children: [
          IconButton(onPressed: () => _inputController.clear(), icon: const Icon(Icons.delete_outline, color: Colors.grey)),
          ElevatedButton(onPressed: _isLoading ? null : _processWithGemini, child: _isLoading && !_isPostEnabled ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Process")),
        ]),
      ]),
      const SizedBox(height: 16),
      TextField(controller: _inputController, maxLines: 5, style: const TextStyle(fontWeight: FontWeight.bold), decoration: InputDecoration(hintText: "Paste raw text here...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))),
    ]),
  );

  Widget _buildOutputSection(ThemeData theme) => Container(
    width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(28)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text("Output", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        IconButton(onPressed: () { Clipboard.setData(ClipboardData(text: _output)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard"))); }, icon: const Icon(Icons.copy_all_rounded, color: Colors.blueAccent)),
      ]),
      const SizedBox(height: 16),
      SelectableText(_output, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
    ]),
  );
}