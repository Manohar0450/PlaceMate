import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Required for API calls
import 'dart:convert'; // Required for JSON handling
// import 'PrincipalRegisterScreen.dart';
import 'package:placemate/PrincipalRegistrationScreen.dart';
import 'PrincipalDashboard.dart';
import 'LoadingScreen.dart';

class PrincipalLoginScreen extends StatefulWidget {
  const PrincipalLoginScreen({super.key});

  @override
  State<PrincipalLoginScreen> createState() => _PrincipalLoginScreenState();
}

class _PrincipalLoginScreenState extends State<PrincipalLoginScreen> {
  bool obscure = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- API LOGIN LOGIC ---
  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    // Validation
    bool isCollegeEmail = RegExp(r"^[a-zA-Z0-9.]+@gmail\.com$").hasMatch(email);
    bool isPasswordStrong = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$').hasMatch(password);

    if (!isCollegeEmail) {
      _showError("Please use a valid @gmail.com address.");
      return;
    }

    if (!isPasswordStrong) {
      _showError("Invalid password format.");
      return;
    }

    // 🔹 1. Show the Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingScreen(message: "Verifying Credentials..."),
    );

    try {
      // 🔹 2. API Call to Vercel
      final url = Uri.parse('https://placemate-backend-coral.vercel.app/login');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      // Remove the loading dialog
      if (mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        // SUCCESS
        final responseData = jsonDecode(response.body);

        // 🔹 UPDATED: Extract both Name and the MongoDB _id
        String principalName = responseData['principal']['name'] ?? "Principal";
        String principalId = responseData['principal']['_id'] ?? "";

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PrincipalDashboard(
                name: principalName,
                principalId: principalId,
                // 🔹 Passing ID to Dashboard
              ),
            ),
          );
        }
      } else {
        // ERROR FROM BACKEND
        final errorData = jsonDecode(response.body);
        _showError(errorData['error'] ?? "Login failed. Please check credentials.");
      }
    } catch (e) {
      // CONNECTION ERROR
      if (mounted) Navigator.pop(context);
      _showError("Cannot connect to server. Ensure your backend is live.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: _card(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Welcome back",
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Change", style: TextStyle(fontWeight: FontWeight.w900)),
                    )
                  ],
                ),
                const Text("Sign in as Principal",
                    style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey)),
                const SizedBox(height: 24),

                _label("Email ID"),
                _input(
                  context,
                  hint: "Enter your mail id",
                  icon: Icons.mail_outline,
                  controller: _emailController,
                ),

                _label("Password"),
                _input(
                  context,
                  hint: "Enter your password",
                  icon: Icons.lock_outline,
                  obscure: obscure,
                  controller: _passwordController,
                  suffix: IconButton(
                    icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                ),

                const SizedBox(height: 20),
                _primaryButton(context, "Sign in", _handleLogin),

                const SizedBox(height: 12),
                _secondaryButton(context, "Register as Principal", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrincipalRegisterScreen()),
                  );
                }),

                const SizedBox(height: 20),
                Center(
                  child: Text("Forgot password? Contact C7.",
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w900)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* --- UI HELPERS (Unchanged) --- */

  Widget _card(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      width: 380,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.4 : 0.12),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
  );

  Widget _input(BuildContext context, {required String hint, required IconData icon, bool obscure = false, Widget? suffix, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontWeight: FontWeight.w900),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _primaryButton(BuildContext context, String text, VoidCallback onTap) {
    return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
            onPressed: onTap,
            child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))
        )
    );
  }

  Widget _secondaryButton(BuildContext context, String text, VoidCallback onTap) {
    return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
            onPressed: onTap,
            child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))
        )
    );
  }
}