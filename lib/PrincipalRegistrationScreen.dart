import 'package:flutter/material.dart';

class PrincipalRegisterScreen extends StatefulWidget {
  const PrincipalRegisterScreen({super.key});

  @override
  State<PrincipalRegisterScreen> createState() => _PrincipalRegisterScreenState();
}

class _PrincipalRegisterScreenState extends State<PrincipalRegisterScreen> {
  // Controllers for all input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _instController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _instController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- REGISTRATION VALIDATION LOGIC ---
  void _handleRegistration() {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    // Rule 1: Email must end with @college.edu
    bool isCollegeEmail = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@gmail\.com$").hasMatch(email);

    // Rule 2: 1 Upper, 1 Lower, 1 Number, 1 Special Character
    bool isPasswordStrong = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$').hasMatch(password);

    if (_nameController.text.isEmpty) {
      _showError("Please enter your full name.");
    } else if (!isCollegeEmail) {
      _showError("Please use a valid @email.com address.");
    } else if (!isPasswordStrong) {
      _showError("Password must have 1 uppercase, 1 lowercase, 1 number, and 1 special character.");
    } else {
      // Logic for successful registration
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully!", style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Return to login
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(),
                      _card(
                        context,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Principal registration",
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Back", style: TextStyle(fontWeight: FontWeight.w900)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text("Create your principal account to access analytics and management.",
                                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 24),

                            _label("Name"),
                            _input(context, hint: "Your full name", icon: Icons.person_outline, controller: _nameController),

                            _label("Email ID"),
                            _input(context, hint: "Enter your mail id", icon: Icons.mail_outline, controller: _emailController),

                            _label("Password"),
                            _input(
                              context,
                              hint: "Enter your password",
                              icon: Icons.lock_outline,
                              controller: _passwordController,
                              obscure: _obscure,
                              suffix: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),

                            _label("Phone"),
                            _input(context, hint: "+91 XXXXXXXXXX", icon: Icons.call_outlined, controller: _phoneController, keyboardType: TextInputType.phone),

                            _label("Institution"),
                            _input(context, hint: "College / University", icon: Icons.apartment_outlined, controller: _instController),

                            const SizedBox(height: 24),
                            _primaryButton(context, "Create account", _handleRegistration),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/* ================= UI HELPERS (BOLDED) ================= */

Widget _card(BuildContext context, {required Widget child}) {
  final theme = Theme.of(context);
  return Container(
    width: MediaQuery.of(context).size.width > 420 ? 380 : double.infinity,
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

Widget _input(BuildContext context, {required String hint, required IconData icon, bool obscure = false, Widget? suffix, TextInputType? keyboardType, TextEditingController? controller}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
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
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
    ),
  );
}