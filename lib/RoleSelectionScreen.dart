import 'package:flutter/material.dart';
import 'package:placemate/CoordinatorLoginScreen.dart';
import 'package:placemate/StudentLoginScreen.dart';
import 'PrincipalLoginScreen.dart';
import 'app_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Stack(
        children: [
          // Ambient orb — top right
          Positioned(
            top: -80, right: -60,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.blue.withOpacity(isDark ? 0.18 : 0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Ambient orb — bottom left
          Positioned(
            bottom: 100, left: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.purple.withOpacity(isDark ? 0.14 : 0.10),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Live badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.12),
                      border: Border.all(color: AppColors.blue.withOpacity(0.25)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.blue, shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'PlaceMate  ·  v2.0',
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500,
                            color: AppColors.blue, letterSpacing: 0.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Headline
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'DMSerifDisplay',
                        fontSize: 36,
                        color: AppColors.text(context),
                        height: 1.15,
                      ),
                      children: const [
                        TextSpan(text: 'Who are\nyou '),
                        TextSpan(
                          text: 'today?',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppColors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your role shapes everything — your dashboard,\nyour tools, your view of what matters.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.muted(context),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _RoleCard(
                    icon: Icons.shield_outlined,
                    title: 'Principal',
                    tag: 'Admin',
                    subtitle: 'Analytics, coordinator oversight & risk overview',
                    iconColor: AppColors.gold,
                    tagColor: AppColors.gold,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PrincipalLoginScreen())),
                  ),
                  const SizedBox(height: 14),
                  _RoleCard(
                    icon: Icons.group_outlined,
                    title: 'Coordinator',
                    tag: 'Manager',
                    subtitle: 'Students, postings & placement pipeline',
                    iconColor: AppColors.blue,
                    tagColor: AppColors.blue,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CoordinatorLoginScreen())),
                  ),
                  const SizedBox(height: 14),
                  _RoleCard(
                    icon: Icons.school_outlined,
                    title: 'Student',
                    tag: 'Learner',
                    subtitle: 'Eligibility, applications & placement updates',
                    iconColor: AppColors.purple,
                    tagColor: AppColors.purple,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const StudentLoginScreen())),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 12, color: AppColors.muted(context)),
                        children: const [
                          TextSpan(text: 'You can change this later in '),
                          TextSpan(
                            text: 'Settings →',
                            style: TextStyle(color: AppColors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String tag;
  final String subtitle;
  final Color iconColor;
  final Color tagColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon, required this.title, required this.tag,
    required this.subtitle, required this.iconColor,
    required this.tagColor, required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Card surfaces — dark uses the original deep navy tones,
    // light uses white/off-white with a soft shadow instead
    final cardNormal  = isDark ? const Color(0xFF13172A) : Colors.white;
    final cardPressed = isDark ? const Color(0xFF1A1F35) : const Color(0xFFEDF0FF);
    final borderNormal  = AppColors.blue.withOpacity(isDark ? 0.15 : 0.18);
    final borderPressed = widget.iconColor.withOpacity(0.35);
    final chevronBg = isDark
        ? Colors.white.withOpacity(0.05)
        : AppColors.blue.withOpacity(0.07);

    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) { setState(() => _hovered = false); widget.onTap(); },
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_hovered ? 0.97 : 1.0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _hovered ? cardPressed : cardNormal,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _hovered ? borderPressed : borderNormal,
          ),
          boxShadow: isDark
              ? null
              : [
            BoxShadow(
              color: AppColors.blue.withOpacity(_hovered ? 0.10 : 0.06),
              blurRadius: _hovered ? 16 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: widget.iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.iconColor.withOpacity(0.2)),
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600,
                        color: AppColors.text(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.tagColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.tag,
                        style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w500,
                          color: widget.tagColor,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.muted(context),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: chevronBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.muted(context),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}