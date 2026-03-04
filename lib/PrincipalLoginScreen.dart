import 'package:flutter/material.dart';
import 'PrincipalRegistrationScreen.dart';
import 'PrincipalDashboard.dart';
import 'LoadingScreen.dart'; // Ensure this matches your filename

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

  // --- UPDATED VALIDATION & NAVIGATION LOGIC ---
  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    // Rule 1: Email must end with @
    // ege.edu
    bool isCollegeEmail = RegExp(r"^[a-zA-Z0-9.]+@gmail\.com$").hasMatch(email);

    // Rule 2: 1 Upper, 1 Lower, 1 Number, 1 Special Character
    bool isPasswordStrong = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$').hasMatch(password);

    if (!isCollegeEmail) {
      _showError("Please use a valid @gmail.com address.");
      return; // Stop execution if validation fails
    }

    if (!isPasswordStrong) {
      _showError("Password must have 1 uppercase, 1 lowercase, 1 number, and 1 special character.");
      return; // Stop execution if validation fails
    }

    // 🔹 1. Show the Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents user from dismissing the loader
      builder: (context) => const LoadingScreen(message: "Accessing Analytics..."),
    );

    // 🔹 2. Wait for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    // 🔹 3. Navigate to Dashboard
    if (mounted) {
      Navigator.pop(context); // Remove the loading dialog first
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PrincipalDashboard(
            email: email.isEmpty ? "Principal" : email,
          ),
        ),
      );
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
    );
  }

  // --- UI HELPERS ---

  Widget _card(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      width: 380,
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