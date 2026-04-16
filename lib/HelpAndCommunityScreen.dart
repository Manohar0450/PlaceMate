import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

class HelpAndCommunityScreen extends StatefulWidget {
  const HelpAndCommunityScreen({super.key});

  @override
  State<HelpAndCommunityScreen> createState() => _HelpAndCommunityScreenState();
}

class _HelpAndCommunityScreenState extends State<HelpAndCommunityScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));

    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic));

    _headerCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () => _contentCtrl.forward());
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _copyEmail(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(text: 'nskmanohar242005@gmail.com'),
    );
    if (!context.mounted) return;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Text('Email copied!', style: TextStyle(fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: const Color(0xFF1D9E75),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppWidgets.screenShell(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: AppWidgets.backAndBadge(
                context: context,
                badgeLabel: 'Help',
                badgeColor: AppColors.gold,
                onBack: () => Navigator.pop(context),
              ),
            ),
          ),
          const SizedBox(height: 28),
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppWidgets.headline(context, 'Help &', 'Community.', AppColors.gold),
                  const SizedBox(height: 8),
                  Text(
                    'Having trouble? Reach out and we\'ll get you sorted.',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.muted(context), height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          FadeTransition(
            opacity: _contentFade,
            child: SlideTransition(
              position: _contentSlide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(label: 'CONTACT SUPPORT'),
                  const SizedBox(height: 10),
                  _EmailCard(onTap: () => _copyEmail(context)),
                  const SizedBox(height: 32),
                  _FancyDivider(label: 'FAQ'),
                  const SizedBox(height: 10),
                  ..._faqs.asMap().entries.map(
                        (e) => _AnimatedFaqTile(
                      index: e.key,
                      question: e.value['q']!,
                      answer: e.value['a']!,
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

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.muted(context).withOpacity(0.6),
      letterSpacing: 1.5,
    ),
  );
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
              fontWeight: FontWeight.w600,
              color: AppColors.muted(context),
              letterSpacing: 1.0)),
    ),
    Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
  ]);
}

class _EmailCard extends StatefulWidget {
  final VoidCallback onTap;
  const _EmailCard({required this.onTap});
  @override
  State<_EmailCard> createState() => _EmailCardState();
}

class _EmailCardState extends State<_EmailCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).cardColor,
                AppColors.gold.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                ),
                child: Icon(Icons.mail_outline_rounded, color: AppColors.gold, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email C7',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color)),
                    const SizedBox(height: 3),
                    Text(
                      'nskmanohar242005@gmail.com',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gold,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(Icons.copy_rounded, color: AppColors.muted(context), size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _faqs = [
  {
    'q': 'How do I reset my password?',
    'a': 'Contact C7 via the email above and request a password reset. Our team responds within 24 hours.',
  },
  {
    'q': 'Why can\'t I log in?',
    'a': 'Make sure you\'re using your registered @gmail.com address and the correct password format.',
  },
  {
    'q': 'How do I update my profile?',
    'a': 'Head to your dashboard and tap the profile icon to edit your details, including your resume and preferences.',
  },
];

class _AnimatedFaqTile extends StatefulWidget {
  final int index;
  final String question;
  final String answer;
  const _AnimatedFaqTile({required this.index, required this.question, required this.answer});

  @override
  State<_AnimatedFaqTile> createState() => _AnimatedFaqTileState();
}

class _AnimatedFaqTileState extends State<_AnimatedFaqTile>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _ctrl;
  late Animation<double> _rotation;
  late Animation<double> _height;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _rotation = Tween<double>(begin: 0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _height = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _open
              ? AppColors.gold.withOpacity(0.04)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _open
                ? AppColors.gold.withOpacity(0.3)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.question,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _open
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : AppColors.muted(context))),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _open ? AppColors.gold.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: RotationTransition(
                    turns: _rotation,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: _open ? AppColors.gold : AppColors.muted(context),
                    ),
                  ),
                ),
              ],
            ),
            SizeTransition(
              sizeFactor: _height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Divider(color: Colors.white.withOpacity(0.07)),
                  const SizedBox(height: 8),
                  Text(widget.answer,
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.muted(context),
                          height: 1.6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}