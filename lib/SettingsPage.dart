import 'package:flutter/material.dart';
import 'package:placemate/AboutAppPage.dart';
import 'package:placemate/Game%20home.dart';
import 'ChangePasswordPage.dart';
import 'DevelopmentTeamPage.dart';
import 'HelpAndCommunityScreen.dart';
import 'NotificationPage.dart';
import 'account_info_page.dart';
import 'session_manager.dart';
import 'SplashScreen.dart';

class SettingsPage extends StatelessWidget {
  final String userId;
  final String userRole; // "principal", "coordinator", or "student"

  const SettingsPage({
    super.key,
    required this.userId,
    required this.userRole,
  });

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardColor,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Logout",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Logout",
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await SessionManager.clearSession();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => SplashScreen()),
              (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AccountInfoPage(
                    userId: userId,
                    userRole: userRole,
                  ),
                ),
              ),
            ),
            _settingsTile(
              theme,
              Icons.lock_outline,
              "Change Password",
              "Update your security credentials",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangePasswordPage(
                    userId: userId,
                    userRole: userRole,
                  ),
                ),
              ),
            ),
            _settingsTile(
              theme,
              Icons.notifications_none,
              "Notifications",
              "View your recent notifications",
              // ✅ Now passing userId and userRole — required by the new NotificationPage
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationPage(
                    userId: userId,
                    userRole: userRole,
                  ),
                ),
              ),
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
                MaterialPageRoute(
                    builder: (_) => const DevelopmentTeamPage()),
              ),
            ),
            _settingsTile(
              theme,
              Icons.info_outline,
              "About App",
              "Version and app information",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutAppPage()),
              ),
            ),
          _settingsTile(
            theme,
            Icons.help_outline_rounded,
            "Help & Community",
            "Support and FAQs",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpAndCommunityScreen()),
            ),
          ),
            _settingsTile(
              theme,
              Icons.games_rounded,
              "Tic Tac Toe",
              "Play classic XO game",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Home()),
              ),
            ),

            const SizedBox(height: 40),
            _logoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 12),
    child: Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.grey)),
  );

  Widget _settingsTile(
      ThemeData theme, IconData icon, String title, String sub,
      {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 22),
        ),
        title:
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing:
        const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () => _handleLogout(context),
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text(
          "Logout",
          style: TextStyle(
              color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}