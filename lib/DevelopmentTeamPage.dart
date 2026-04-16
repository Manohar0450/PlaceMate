import 'package:flutter/material.dart';

class DevelopmentTeamPage extends StatefulWidget {
  const DevelopmentTeamPage({super.key});

  @override
  State<DevelopmentTeamPage> createState() => _DevelopmentTeamPageState();
}

class _DevelopmentTeamPageState extends State<DevelopmentTeamPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _fades;
  late List<Animation<Offset>> _slides;

  // 1 banner + 4 dev cards + divider + mentor = 7 items
  static const int _itemCount = 7;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _fades = List.generate(_itemCount, (i) {
      final start = i * 0.09;
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start.clamp(0.0, 0.8), (start + 0.3).clamp(0.0, 1.0), curve: Curves.easeOut)));
    });
    _slides = List.generate(_itemCount, (i) {
      final start = i * 0.09;
      return Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _ctrl,
              curve: Interval(start.clamp(0.0, 0.8), (start + 0.3).clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic)));
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _animated(int i, Widget child) => FadeTransition(
    opacity: _fades[i],
    child: SlideTransition(position: _slides[i], child: child),
  );

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
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(Icons.chevron_left_rounded),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _animated(0, _PassionBanner()),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text("MEET THE TEAM",
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: theme.colorScheme.onSurface.withOpacity(0.4))),
            ),

            _animated(1, _DevCard(initials: "MN", name: "Manohar Nallamsetty", role: "Full Stack Developer", email: "nskmanohar242005@gmail.com", avatarColor: const Color(0xFF4ADE80))),
            _animated(2, _DevCard(initials: "MC", name: "Mithun Chavakula", role: "ML Developer", email: "mithunchavakula@gmail.com", avatarColor: const Color(0xFF60A5FA))),
            _animated(3, _DevCard(initials: "CJ", name: "Ch Jithendra", role: "UI/UX Designer", email: "jithendra@gmail.com", avatarColor: const Color(0xFFA78BFA))),
            _animated(4, _DevCard(initials: "SK", name: "Seshu Kanda", role: "Tester", email: "seshu@gmail.com", avatarColor: const Color(0xFFFB923C))),

            const SizedBox(height: 8),

            _animated(5, _FancyDivider(label: "Project Mentor")),
            const SizedBox(height: 16),

            _animated(6, const _MentorCard()),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _PassionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF4ADE80).withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4ADE80).withOpacity(0.18)),
      ),
      child: const Text(
        "Developed with passion by our talented team",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Color(0xFF4ADE80), fontWeight: FontWeight.w500, fontSize: 13),
      ),
    );
  }
}

class _FancyDivider extends StatelessWidget {
  final String label;
  const _FancyDivider({required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
    ),
    Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
  ]);
}

class _DevCard extends StatefulWidget {
  final String initials;
  final String name;
  final String role;
  final String email;
  final Color avatarColor;

  const _DevCard({
    required this.initials,
    required this.name,
    required this.role,
    required this.email,
    required this.avatarColor,
  });

  @override
  State<_DevCard> createState() => _DevCardState();
}

class _DevCardState extends State<_DevCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        transform: Matrix4.translationValues(0, _pressed ? 1 : -2, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _pressed
                ? widget.avatarColor.withOpacity(0.3)
                : Colors.white.withOpacity(0.08),
          ),
          boxShadow: _pressed
              ? []
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: widget.avatarColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.avatarColor.withOpacity(0.2)),
              ),
              alignment: Alignment.center,
              child: Text(widget.initials,
                  style: TextStyle(
                      color: widget.avatarColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: 0.5)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.avatarColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(widget.role,
                        style: TextStyle(
                            color: widget.avatarColor, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(Icons.mail_outline_rounded,
                          size: 13,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35)),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(widget.email,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
                                fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
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

class _MentorCard extends StatelessWidget {
  const _MentorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1020), Color(0xFF111828)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF60A5FA).withOpacity(0.06),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF60A5FA).withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.25)),
            ),
            child: const Icon(Icons.auto_awesome_outlined,
                color: Color(0xFF60A5FA), size: 22),
          ),
          const SizedBox(height: 14),
          Text("GUIDED BY",
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                  letterSpacing: 1.5)),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
            ).createShader(bounds),
            child: const Text("Sailaja",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24)),
          ),
          const SizedBox(height: 8),
          Text("This project was developed under her expert guidance",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
                  fontSize: 13,
                  height: 1.5)),
        ],
      ),
    );
  }
}