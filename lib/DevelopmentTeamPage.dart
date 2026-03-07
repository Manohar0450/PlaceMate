import 'package:flutter/material.dart';
class DevelopmentTeamPage extends StatelessWidget {
  const DevelopmentTeamPage({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Development Team", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Top Passion Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: const Text(
                "Developed with passion by our talented team",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 32),

            /// Meet the Team Title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Meet the Team",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),


            _devCard(
              theme,
              name: "Manohar Nallamsetty",
              role: "Backend Developer",
              email: "nskmanohar242005@gmail.com",
              icon: Icons.laptop_mac,
              roleColor: Colors.green,
            ),
            _devCard(
              theme,
              name: "Mithun Chavakula",
              role: "ML Developer",
              email: "MithunChavakula@gmail.com",
              icon: Icons.smart_toy_outlined,
              roleColor: Colors.blueAccent,
            ),
            _devCard(
              theme,
              name: "Ch Jithendra",
              role: "UI/UX Designer",
              email:"JithuParul@gmail.com",
              // email: "Jithendraramarao@gmail.com",
              icon: Icons.palette_outlined,
              roleColor: Colors.tealAccent,
            ),
            _devCard(
              theme,
              name: "Seshu Kanda",
              role: "Frontend Developer",
              email: "Seshu@gmail.com",
              icon: Icons.settings_outlined,
              roleColor: Colors.orangeAccent,
            ),

            const SizedBox(height: 32),

            /// Project Mentor Section
            _mentorCard(theme),
          ],
        ),
      ),
    );
  }


  Widget _devCard(ThemeData theme, {
    required String name,
    required String role,
    required String email,
    required IconData icon,
    required Color roleColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          //  Icon Avatar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 28),
          ),
          const SizedBox(width: 20),

          /// Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 6),

                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                // Email Row
                Row(
                  children: [
                    const Icon(Icons.mail_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Helper Widget for the Mentor Card
  Widget _mentorCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          const Icon(Icons.school_outlined, color: Colors.blueAccent, size: 40),
          const SizedBox(height: 16),
          const Text(
            "Project Mentor",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 12),
          const Text(
            "This project was developed under the guidance of",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            "Sailaja",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}