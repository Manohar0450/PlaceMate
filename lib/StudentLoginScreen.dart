// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'StudentDashboard.dart';
// import 'LoadingScreen.dart';
// import 'session_manager.dart';
//
// class StudentLoginScreen extends StatefulWidget {
//   const StudentLoginScreen({super.key});
//
//   @override
//   State<StudentLoginScreen> createState() => _StudentLoginScreenState();
// }
//
// class _StudentLoginScreenState extends State<StudentLoginScreen> {
//   bool obscure = true;
//   final TextEditingController _idController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   @override
//   void dispose() {
//     _idController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   void _handleLogin() async {
//     String rollId = _idController.text.trim();
//     String password = _passwordController.text;
//
//     if (rollId.isEmpty || password.isEmpty) {
//       _showError("Please enter your Roll ID and Password.");
//       return;
//     }
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => const LoadingScreen(message: "Verifying Student..."),
//     );
//
//     try {
//       final response = await http.post(
//         Uri.parse(
//             'https://placemate-backend-coral.vercel.app/student/login'),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"rollId": rollId, "password": password}),
//       );
//
//       if (mounted) Navigator.pop(context);
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final student = data['student'] as Map<String, dynamic>;
//
//         // ── SAVE SESSION ──────────────────────────────────────────────────
//         await SessionManager.saveSession(
//           userData: student,
//           role: 'student',
//           userId: student['rollId'] ?? rollId,
//         );
//
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (_) => StudentDashboard(studentData: student)),
//           );
//         }
//       } else {
//         final err = jsonDecode(response.body);
//         _showError(err['error'] ?? "Login failed. Check your credentials.");
//       }
//     } catch (e) {
//       if (mounted) Navigator.pop(context);
//       _showError("Connection failed. Check your internet.");
//     }
//   }
//
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content:
//         Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
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
//                             ?.copyWith(fontWeight: FontWeight.bold)),
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text("Change",
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                     )
//                   ],
//                 ),
//                 Text("Sign in as Student",
//                     style: theme.textTheme.bodyMedium
//                         ?.copyWith(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 24),
//                 _label("Roll Number / ID"),
//                 _input(context,
//                     hint: "Roll Number",
//                     icon: Icons.badge_outlined,
//                     controller: _idController),
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
//                 const SizedBox(height: 20),
//                 Center(
//                   child: Text("Forgot password? Contact Coordinator.",
//                       style: theme.textTheme.bodySmall
//                           ?.copyWith(fontWeight: FontWeight.bold)),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// Widget _card(BuildContext context, {required Widget child}) {
//   final theme = Theme.of(context);
//   return Container(
//     width: 380,
//     margin: const EdgeInsets.symmetric(horizontal: 16),
//     padding: const EdgeInsets.all(24),
//     decoration: BoxDecoration(
//       color: theme.cardColor,
//       borderRadius: BorderRadius.circular(28),
//       boxShadow: [
//         BoxShadow(
//           blurRadius: 30,
//           color: Colors.black
//               .withOpacity(theme.brightness == Brightness.dark ? 0.4 : 0.12),
//         ),
//       ],
//     ),
//     child: child,
//   );
// }
//
// Widget _label(String text) => Padding(
//   padding: const EdgeInsets.only(bottom: 6),
//   child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
// );
//
// Widget _input(BuildContext context,
//     {required String hint,
//       required IconData icon,
//       bool obscure = false,
//       Widget? suffix,
//       TextEditingController? controller}) {
//   return Padding(
//     padding: const EdgeInsets.only(bottom: 16),
//     child: TextField(
//       controller: controller,
//       obscureText: obscure,
//       style: const TextStyle(fontWeight: FontWeight.bold),
//       decoration: InputDecoration(
//         hintText: hint,
//         prefixIcon: Icon(icon),
//         suffixIcon: suffix,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//       ),
//     ),
//   );
// }
//
// Widget _primaryButton(
//     BuildContext context, String text, VoidCallback onTap) {
//   return SizedBox(
//     width: double.infinity,
//     height: 52,
//     child: ElevatedButton(
//       onPressed: onTap,
//       child: Text(text,
//           style: const TextStyle(fontWeight: FontWeight.bold)),
//     ),
//   );
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_theme.dart';
import 'StudentDashboard.dart';
import 'LoadingScreen.dart';
import 'session_manager.dart';

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});
  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  bool _obscure = true;
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() { _idCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _handleLogin() async {
    final rollId = _idCtrl.text.trim(); final password = _passCtrl.text;
    if (rollId.isEmpty || password.isEmpty) { _showError("Please enter your Roll ID and Password."); return; }
    showDialog(context: context, barrierDismissible: false,
        builder: (_) => const LoadingScreen(message: "Verifying Student..."));
    try {
      final res = await http.post(
        Uri.parse('https://placemate-backend-coral.vercel.app/student/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"rollId": rollId, "password": password}),
      );
      if (mounted) Navigator.pop(context);
      if (res.statusCode == 200) {
        final student = jsonDecode(res.body)['student'] as Map<String, dynamic>;
        await SessionManager.saveSession(userData: student, role: 'student', userId: student['rollId'] ?? rollId);
        if (mounted) Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => StudentDashboard(studentData: student)));
      } else { _showError(jsonDecode(res.body)['error'] ?? "Login failed."); }
    } catch (_) { if (mounted) Navigator.pop(context); _showError("Connection failed."); }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
    backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ));

  @override
  Widget build(BuildContext context) => AppWidgets.screenShell(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppWidgets.backAndBadge(context: context, badgeLabel: 'Student',
          badgeColor: AppColors.purple, onBack: () => Navigator.pop(context)),
      const SizedBox(height: 28),
      AppWidgets.headline('Welcome', 'back.', AppColors.purple),
      const SizedBox(height: 8),
      const Text('Sign in to track your placement journey.',
          style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5)),
      const SizedBox(height: 28),
      AppWidgets.fieldLabel('Roll number / ID'),
      AppWidgets.inputField(icon: Icons.badge_outlined, hint: 'e.g. 22CS101', controller: _idCtrl),
      AppWidgets.fieldLabel('Password'),
      AppWidgets.inputField(
        icon: Icons.lock_outline_rounded, hint: '••••••••••',
        obscure: _obscure, controller: _passCtrl,
        suffix: IconButton(
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.muted, size: 18),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      const SizedBox(height: 8),
      AppWidgets.primaryButton('Sign in', AppColors.purple, _handleLogin),
      const SizedBox(height: 24),
      AppWidgets.footerNote('Forgot password? ', 'Contact Coordinator', null),
    ],
  ));
}