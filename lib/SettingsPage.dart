import 'package:flutter/material.dart';
import 'DevelopmentTeamPage.dart'; // Ensure this matches your file name

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Reusable "Coming Soon" Dialog
  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text("Coming Soon", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            "This feature is under development and will be available soon.",
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(color: Color(0xFF6C9EFF), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // appBar: AppBar(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel("Account"),
            _settingsTile(
              theme,
              Icons.person_outline,
              "Account Information",
              "View your profile details",
              onTap: () => _showComingSoonDialog(context),
            ),
            _settingsTile(
              theme,
              Icons.lock_outline,
              "Change Password",
              "Update your security credentials",
              onTap: () => _showComingSoonDialog(context),
            ),
            _settingsTile(
              theme,
              Icons.notifications_none,
              "Notifications",
              "Manage notification preferences",
              onTap: () => _showComingSoonDialog(context),
            ),

            const SizedBox(height: 32),
            _sectionLabel("App"),
            _settingsTile(
              theme,
              Icons.code,
              "Developers",
              "Meet the development team",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DevelopmentTeamPage()),
              ),
            ),
            _settingsTile(
              theme,
              Icons.shield_outlined,
              "Privacy Policy",
              "View our privacy policy",
              onTap: () => _showComingSoonDialog(context),
            ),
            _settingsTile(
              theme,
              Icons.description_outlined,
              "Terms of Service",
              "Read terms and conditions",
              onTap: () => _showComingSoonDialog(context),
            ),
            _settingsTile(
              theme,
              Icons.info_outline,
              "About App",
              "Version and app information",
              onTap: () => _showComingSoonDialog(context),
            ),

            const SizedBox(height: 40),

            // Logout Button
            _logoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 12),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
  );

  Widget _settingsTile(ThemeData theme, IconData icon, String title, String sub, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text(
          "Logout",
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}