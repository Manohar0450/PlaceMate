// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:placemate/PrincipalRegistrationScreen.dart';
// import 'PrincipalDashboard.dart';
// import 'LoadingScreen.dart';
// import 'session_manager.dart';
//
// class PrincipalLoginScreen extends StatefulWidget {
//   const PrincipalLoginScreen({super.key});
//
//   @override
//   State<PrincipalLoginScreen> createState() => _PrincipalLoginScreenState();
// }
//
// class _PrincipalLoginScreenState extends State<PrincipalLoginScreen> {
//   bool obscure = true;
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleLogin() async {
//     String email = _emailController.text.trim();
//     String password = _passwordController.text;
//
//     bool isValidEmail =
//     RegExp(r"^[a-zA-Z0-9.]+@gmail\.com$").hasMatch(email);
//     bool isPasswordStrong =
//     RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$')
//         .hasMatch(password);
//
//     if (!isValidEmail) {
//       _showError("Please use a valid @gmail.com address.");
//       return;
//     }
//     if (!isPasswordStrong) {
//       _showError("Invalid password format.");
//       return;
//     }
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const LoadingScreen(message: "Verifying Credentials..."),
//     );
//
//     try {
//       final response = await http.post(
//         Uri.parse('https://placemate-backend-coral.vercel.app/login'),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"email": email, "password": password}),
//       );
//
//       if (mounted) Navigator.pop(context);
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final principal = data['principal'] as Map<String, dynamic>;
//         final String principalId = principal['_id'] ?? "";
//         final String principalName = principal['name'] ?? "Principal";
//
//         // ── SAVE SESSION ──────────────────────────────────────────────────
//         await SessionManager.saveSession(
//           userData: principal,
//           role: 'principal',
//           userId: principalId,
//         );
//
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (_) => PrincipalDashboard(
//                 name: principalName,
//                 principalId: principalId,
//               ),
//             ),
//           );
//         }
//       } else {
//         final err = jsonDecode(response.body);
//         _showError(err['error'] ?? "Login failed. Please check credentials.");
//       }
//     } catch (e) {
//       if (mounted) Navigator.pop(context);
//       _showError("Cannot connect to server. Ensure your backend is live.");
//     }
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content:
//         Text(message, style: const TextStyle(fontWeight: FontWeight.w900)),
//         backgroundColor: Colors.redAccent,
//         behavior: SnackBarBehavior.floating,
//         shape:
//         RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           child: _card(
//             context,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text("Welcome back",
//                         style: theme.textTheme.titleLarge
//                             ?.copyWith(fontWeight: FontWeight.w900)),
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text("Change",
//                           style: TextStyle(fontWeight: FontWeight.w900)),
//                     )
//                   ],
//                 ),
//                 const Text("Sign in as Principal",
//                     style: TextStyle(
//                         fontWeight: FontWeight.w900, color: Colors.grey)),
//                 const SizedBox(height: 24),
//                 _label("Email ID"),
//                 _input(context,
//                     hint: "Enter your mail id",
//                     icon: Icons.mail_outline,
//                     controller: _emailController),
//                 _label("Password"),
//                 _input(
//                   context,
//                   hint: "Enter your password",
//                   icon: Icons.lock_outline,
//                   obscure: obscure,
//                   controller: _passwordController,
//                   suffix: IconButton(
//                     icon: Icon(obscure
//                         ? Icons.visibility_outlined
//                         : Icons.visibility_off_outlined),
//                     onPressed: () => setState(() => obscure = !obscure),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 _primaryButton(context, "Sign in", _handleLogin),
//                 const SizedBox(height: 12),
//                 _secondaryButton(context, "Register as Principal", () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (_) => const PrincipalRegisterScreen()),
//                   );
//                 }),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: Text("Forgot password? Contact C7.",
//                       style: theme.textTheme.bodySmall
//                           ?.copyWith(fontWeight: FontWeight.w900)),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _card(BuildContext context, {required Widget child}) {
//     final theme = Theme.of(context);
//     return Container(
//       width: 380,
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 30,
//             color: Colors.black.withOpacity(
//                 theme.brightness == Brightness.dark ? 0.4 : 0.12),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
//
//   Widget _label(String text) => Padding(
//     padding: const EdgeInsets.only(bottom: 6),
//     child:
//     Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
//   );
//
//   Widget _input(BuildContext context,
//       {required String hint,
//         required IconData icon,
//         bool obscure = false,
//         Widget? suffix,
//         TextEditingController? controller}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextField(
//         controller: controller,
//         obscureText: obscure,
//         style: const TextStyle(fontWeight: FontWeight.w900),
//         decoration: InputDecoration(
//           hintText: hint,
//           prefixIcon: Icon(icon),
//           suffixIcon: suffix,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//         ),
//       ),
//     );
//   }
//
//   Widget _primaryButton(
//       BuildContext context, String text, VoidCallback onTap) {
//     return SizedBox(
//       width: double.infinity,
//       height: 52,
//       child: ElevatedButton(
//         onPressed: onTap,
//         child: Text(text,
//             style: const TextStyle(
//                 fontWeight: FontWeight.w900, fontSize: 16)),
//       ),
//     );
//   }
//
//   Widget _secondaryButton(
//       BuildContext context, String text, VoidCallback onTap) {
//     return SizedBox(
//       width: double.infinity,
//       height: 52,
//       child: OutlinedButton(
//         onPressed: onTap,
//         child: Text(text,
//             style: const TextStyle(
//                 fontWeight: FontWeight.w900, fontSize: 16)),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'help_page.dart';
import 'dart:convert';
import 'package:placemate/HelpAndCommunityScreen.dart';
import 'app_theme.dart';
import 'PrincipalRegistrationScreen.dart';
import 'PrincipalDashboard.dart';
import 'LoadingScreen.dart';
import 'session_manager.dart';

class PrincipalLoginScreen extends StatefulWidget {
  const PrincipalLoginScreen({super.key});
  @override
  State<PrincipalLoginScreen> createState() => _PrincipalLoginScreenState();
}

class _PrincipalLoginScreenState extends State<PrincipalLoginScreen> {
  bool _obscure = true;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    if (!RegExp(r"^[a-zA-Z0-9.]+@gmail\.com$").hasMatch(email)) {
      _showError("Please use a valid @gmail.com address."); return;
    }
    if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$').hasMatch(password)) {
      _showError("Invalid password format."); return;
    }
    showDialog(
      context: context, barrierDismissible: false,
      builder: (_) => const LoadingScreen(message: "Verifying Credentials..."),
    );
    try {
      final res = await http.post(
        Uri.parse('https://placemate-backend-coral.vercel.app/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      if (mounted) Navigator.pop(context);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final principal = data['principal'] as Map<String, dynamic>;
        final id = principal['_id'] ?? "";
        final name = principal['name'] ?? "Principal";
        await SessionManager.saveSession(userData: principal, role: 'principal', userId: id);
        if (mounted) Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => PrincipalDashboard(name: name, principalId: id)));
      } else {
        _showError(jsonDecode(res.body)['error'] ?? "Login failed.");
      }
    } catch (_) {
      if (mounted) Navigator.pop(context);
      _showError("Cannot connect to server.");
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
    backgroundColor: Colors.redAccent,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ));

  @override
  Widget build(BuildContext context) {
    return AppWidgets.screenShell(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppWidgets.backAndBadge(
            context: context, badgeLabel: 'Principal',
            badgeColor: AppColors.gold, onBack: () => Navigator.pop(context),
          ),
          const SizedBox(height: 28),
          AppWidgets.headline(context, 'Welcome', 'back.', AppColors.gold),
          const SizedBox(height: 8),
          Text(
            'Sign in to access your analytics dashboard.',
            style: TextStyle(fontSize: 13, color: AppColors.muted(context), height: 1.5),
          ),
          const SizedBox(height: 28),
          AppWidgets.fieldLabel(context, 'Email address'),
          AppWidgets.inputField(context,
              icon: Icons.mail_outline_rounded,
              hint: 'principal@gmail.com',
              controller: _emailCtrl),
          AppWidgets.fieldLabel(context, 'Password'),
          AppWidgets.inputField(context,
            icon: Icons.lock_outline_rounded, hint: '••••••••••',
            obscure: _obscure, controller: _passCtrl,
            suffix: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.muted(context), size: 18,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: 8),
          AppWidgets.primaryButton('Sign in', AppColors.gold, _handleLogin),
          const SizedBox(height: 12),
          AppWidgets.secondaryButton('Register as Principal', AppColors.gold, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PrincipalRegisterScreen()));
          }),
          const SizedBox(height: 24),
          AppWidgets.footerNote(
            context,
            'Forgot password? ',
            'Contact C7',
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpAndCommunityScreen()),
              );
            },
          ),
          // AppWidgets.footerNote(context, 'Forgot password? ', 'Contact C7', null),
        ],
      ),
    );
  }
}