import 'package:flutter/material.dart';

class DevelopmentTeamPage extends StatelessWidget {
  const DevelopmentTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Development Team", style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _passionBadge(),
            const SizedBox(height: 28),
            _sectionDivider("Meet the Team"),
            const SizedBox(height: 16),
            _devCard(theme, initials: "MN", name: "Manohar Nallamsetty", role: "Full Stack Developer", email: "nskmanohar242005@gmail.com", avatarColor: Colors.green),
            _devCard(theme, initials: "MC", name: "Mithun Chavakula", role: "ML Developer", email: "mithunchavakula@gmail.com", avatarColor: Colors.blueAccent),
            _devCard(theme, initials: "CJ", name: "Ch Jithendra", role: "UI/UX Designer", email: "jithendra@gmail.com", avatarColor: const Color(0xFF1D9E75)),
            _devCard(theme, initials: "SK", name: "Seshu Kanda", role: "Tester", email: "seshu@gmail.com", avatarColor: Colors.orangeAccent),
            const SizedBox(height: 24),
            _sectionDivider("Project Mentor"),
            const SizedBox(height: 16),
            _mentorCard(theme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _passionBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2), width: 0.5),
      ),
      child: const Text(
        "Developed with passion by our talented team",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500, fontSize: 13),
      ),
    );
  }

  Widget _sectionDivider(String label) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 0.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
        ),
        const Expanded(child: Divider(thickness: 0.5)),
      ],
    );
  }

  Widget _devCard(ThemeData theme, {
    required String initials,
    required String name,
    required String role,
    required String email,
    required Color avatarColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          // Initials avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: avatarColor.withOpacity(0.12),
            child: Text(initials, style: TextStyle(color: avatarColor, fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: avatarColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(role, style: TextStyle(color: avatarColor, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.mail_outline, size: 13, color: Colors.grey.withOpacity(0.7)),
                    const SizedBox(width: 5),
                    Flexible(child: Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mentorCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_outlined, color: Colors.blueAccent, size: 20),
          ),
          const SizedBox(height: 14),
          const Text("GUIDED BY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.0)),
          const SizedBox(height: 6),
          const Text("Sailaja", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 20)),
          const SizedBox(height: 6),
          const Text("This project was developed under her guidance", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}