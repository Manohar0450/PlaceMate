import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        // Explicit Back Arrow for navigation
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
            "Notifications",
            style: TextStyle(fontWeight: FontWeight.bold)
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Welcome Badge (Inspired by your "Passion Badge")
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.celebration_outlined, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "You're all set! Your journey starts here.",
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              "Recent Activity",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// Primary Account Notification
            _notificationCard(
              theme,
              title: "Account Successfully Created",
              message: "Welcome! Your account has been created. You can now access all features and collaborate with the team.",
              time: "Just now",
              icon: Icons.person_add_alt_1_rounded,
              accentColor: Colors.blueAccent,
              isUnread: true,
            ),

            /// Security Notification
            _notificationCard(
              theme,
              title: "Security Update",
              message: "We recommend enabling Two-Factor Authentication (2FA) in your account settings.",
              time: "2 mins ago",
              icon: Icons.shield_moon_outlined,
              accentColor: Colors.orangeAccent,
              isUnread: true,
            ),

            /// General Update
            _notificationCard(
              theme,
              title: "Explore the Team",
              message: "Check out the Development Team page to see the talented people behind this project.",
              time: "5 mins ago",
              icon: Icons.groups_2_outlined,
              accentColor: Colors.tealAccent,
              isUnread: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationCard(ThemeData theme, {
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required Color accentColor,
    required bool isUnread,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container (Matches _devCard style)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 26),
          ),
          const SizedBox(width: 16),

          /// Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    if (isUnread)
                      const CircleAvatar(
                          radius: 4,
                          backgroundColor: Colors.blueAccent
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      height: 1.4
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  time,
                  style: TextStyle(
                      color: theme.hintColor.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}