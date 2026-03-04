import 'package:flutter/material.dart';
import 'package:placemate/CoordinatorLoginScreen.dart';
import 'package:placemate/StudentLoginScreen.dart';
import 'PrincipalLoginScreen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // The Scaffold background will now change based on your main.dart theme
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 380,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    theme.brightness == Brightness.dark ? 0.4 : 0.08,
                  ),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Choose your role",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "We'll personalize your navigation and dashboard.",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                /// Principal Navigation
                _roleCard(
                  context,
                  icon: Icons.shield_outlined,
                  title: "Principal",
                  subtitle: "Placement analytics, coordinator management, risk overview",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrincipalLoginScreen()),
                  ),
                ),
                const SizedBox(height: 16),

                /// Coordinator Navigation
                _roleCard(
                  context,
                  icon: Icons.group_outlined,
                  title: "Coordinator",
                  subtitle: "Manage students, postings, and placement pipeline",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CoordinatorLoginScreen()),
                  ),
                ),
                const SizedBox(height: 16),

                /// Student Navigation
                _roleCard(
                  context,
                  icon: Icons.school_outlined,
                  title: "Student",
                  subtitle: "Track eligibility, apply to placements, and see updates",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentLoginScreen()),
                  ),
                ),
                // const SizedBox(height: 32),
                //
                // Text(
                //   "You can change later in Settings.",
                //   style: theme.textTheme.bodySmall,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);

    // This helps the card look distinct from the background container
    final itemBgColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surface.withOpacity(0.5)
        : theme.scaffoldBackgroundColor.withOpacity(0.5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: itemBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.05),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}