import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PrincipalRegisterScreen extends StatefulWidget {
  const PrincipalRegisterScreen({super.key});

  @override
  State<PrincipalRegisterScreen> createState() =>
      _PrincipalRegisterScreenState();
}

class _PrincipalRegisterScreenState extends State<PrincipalRegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _instController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _instController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final phone = _phoneController.text.trim();
    final inst = _instController.text.trim();

    // Validation logic...
    bool isNameValid = RegExp(r'^[a-zA-Z\s]{3,}$').hasMatch(name);
    bool isCollegeEmail = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@gmail\.com$").hasMatch(email);
    bool isPasswordStrong = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$').hasMatch(password);
    bool isPhoneValid = RegExp(r'^[0-9]{10}$').hasMatch(phone);
    bool isInstitutionValid = RegExp(r'^[a-zA-Z0-9\s]{3,}$').hasMatch(inst);

    if (!isNameValid) { _showError("Name must contain at least 3 letters."); return; }
    if (!isCollegeEmail) { _showError("Please use a valid @gmail.com address."); return; }
    if (!isPasswordStrong) { _showError("Password must contain uppercase, lowercase, number and special character."); return; }
    if (!isPhoneValid) { _showError("Phone number must be exactly 10 digits."); return; }
    if (!isInstitutionValid) { _showError("Institution name must contain at least 3 characters."); return; }

    setState(() => _isLoading = true);

    try {
      final vercelUrl = Uri.parse('https://placemate-backend-coral.vercel.app/register');
      final response = await http.post(
        vercelUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "phone": phone,
          "institution": inst,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP sent to your email!", style: TextStyle(fontWeight: FontWeight.w900)),
            backgroundColor: Colors.blue,
          ),
        );

        // NAVIGATE TO OTP SCREEN
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(email: email),
          ),
        );
      } else {
        final errorData = jsonDecode(response.body);
        _showError(errorData['error'] ?? "Registration failed.");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Connection failed. Check your internet.");
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
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Principal registration",
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Back", style: TextStyle(fontWeight: FontWeight.w900)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text("Create your principal account to access analytics.",
                              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 24),
                            _label("Name"),
                            _input(context, hint: "Your full name", icon: Icons.person_outline, controller: _nameController),
                            _label("Email ID"),
                            _input(context, hint: "Enter your mail id", icon: Icons.mail_outline, controller: _emailController),
                            _label("Password"),
                            _input(context, hint: "Enter your password", icon: Icons.lock_outline, controller: _passwordController, obscure: _obscure,
                              suffix: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            _label("Phone"),
                            _input(context, hint: "XXXXXXXXXX", icon: Icons.call_outlined, controller: _phoneController, keyboardType: TextInputType.number),
                            _label("Institution"),
                            _input(context, hint: "College / University", icon: Icons.apartment_outlined, controller: _instController),
                            const SizedBox(height: 24),
                            _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : _primaryButton(context, "Create account", _handleRegistration),
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

// --- NEW VERIFICATION SCREEN ---

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      _showStatus("Please enter the 6-digit OTP", Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://placemate-backend-coral.vercel.app/verify-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email, "otp": otp}),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        if (!mounted) return;
        _showStatus("Account verified! You can now login.", Colors.green);
        Navigator.pop(context); // Go back to login screen
      } else {
        final errorData = jsonDecode(response.body);
        _showStatus(errorData['error'] ?? "Verification failed.", Colors.redAccent);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showStatus("Connection failed.", Colors.redAccent);
    }
  }

  void _showStatus(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _card(
              context,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mark_email_unread_outlined, size: 60, color: Colors.blue),
                  const SizedBox(height: 20),
                  const Text("Verify Email", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text("We've sent a 6-digit code to\n${widget.email}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  _label("Verification Code"),
                  _input(context,
                    hint: "XXXXXX",
                    icon: Icons.vpn_key_outlined,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : _primaryButton(context, "Verify & Activate", _handleVerify),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.redAccent)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- SHARED UI HELPERS (Keep these at the bottom) ---

Widget _card(BuildContext context, {required Widget child}) {
  final theme = Theme.of(context);
  return Container(
    width: MediaQuery.of(context).size.width > 420 ? 380 : double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(blurRadius: 30, color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.4 : 0.12)),
      ],
    ),
    child: child,
  );
}

Widget _label(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
  );
}

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