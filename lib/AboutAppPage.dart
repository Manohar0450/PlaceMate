import 'package:flutter/material.dart';

class AboutAppPage extends StatefulWidget {
  const AboutAppPage({super.key});

  @override
  State<AboutAppPage> createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _staggerCtrl;
  late Animation<double> _logoFloat;
  late Animation<double> _logoPulse;
  late List<Animation<double>> _itemFades;
  late List<Animation<Offset>> _itemSlides;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _staggerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _logoFloat = Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeInOut));
    _logoPulse = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeInOut));

    // 6 staggered items (logo area, mission, section label, 4 features)
    _itemFades = List.generate(7, (i) {
      final start = i * 0.08;
      return Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start.clamp(0, 0.85), (start + 0.3).clamp(0, 1), curve: Curves.easeOut)));
    });
    _itemSlides = List.generate(7, (i) {
      final start = i * 0.08;
      return Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
          .animate(CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start.clamp(0, 0.85), (start + 0.3).clamp(0, 1), curve: Curves.easeOutCubic)));
    });

    _staggerCtrl.forward();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _staggerCtrl.dispose();
    super.dispose();
  }

  Widget _animated(int i, Widget child) => FadeTransition(
    opacity: _itemFades[i],
    child: SlideTransition(position: _itemSlides[i], child: child),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const gold = Color(0xFFC9A84C);
    const goldLight = Color(0xFFE8C97A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("About App", style: TextStyle(fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            // --- Logo Area ---
            _animated(
              0,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _logoCtrl,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _logoFloat.value),
                        child: Transform.scale(
                          scale: _logoPulse.value,
                          child: child,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring (pulsing)
                          AnimatedBuilder(
                            animation: _logoCtrl,
                            builder: (_, __) => Container(
                              width: 110 + _logoPulse.value * 4,
                              height: 110 + _logoPulse.value * 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(38),
                                border: Border.all(
                                  color: gold.withOpacity(0.15 + _logoPulse.value * 0.1),
                                ),
                              ),
                            ),
                          ),
                          // Main logo container
                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1A1A2A), Color(0xFF0D1020)],
                              ),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: gold.withOpacity(0.35)),
                              boxShadow: [
                                BoxShadow(
                                  color: gold.withOpacity(0.18),
                                  blurRadius: 32,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.business_center_rounded,
                                size: 40, color: gold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [goldLight, gold],
                      ).createShader(bounds),
                      child: const Text(
                        "Placemate",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text("Version 1.0.0",
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.45), fontSize: 13)),
                  ],
                ),
              ),
            ),

            // --- Mission Card ---
            _animated(
              1,
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF111120),
                      theme.cardColor.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFF4ADE80).withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4ADE80).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.rocket_launch_outlined,
                              color: Color(0xFF4ADE80), size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Text("Our Mission",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Placemate bridges the gap between students and career opportunities by streamlining the placement process through an intuitive digital interface.",
                      style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.55),
                          height: 1.7,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            // --- Key Features ---
            _animated(
              2,
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Text("Key Features",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                ),
              ),
            ),

            ..._features.asMap().entries.map((e) => _animated(
              e.key + 3,
              _FeatureItem(
                label: e.value.label,
                icon: e.value.icon,
                color: e.value.color,
              ),
            )),

            const SizedBox(height: 28),
            Text(
              "© 2026 Placemate Project Team",
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.25), fontSize: 12),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FeatureData {
  final String label;
  final IconData icon;
  final Color color;
  const _FeatureData(this.label, this.icon, this.color);
}

const _features = [
  _FeatureData("Seamless Registration", Icons.person_add_alt_1_outlined, Color(0xFFA78BFA)),
  _FeatureData("Real-time Notifications", Icons.notifications_active_outlined, Color(0xFFFBBF24)),
  _FeatureData("Placement Analytics", Icons.bar_chart_rounded, Color(0xFF60A5FA)),
  _FeatureData("Document Management", Icons.description_outlined, Color(0xFF4ADE80)),
];

class _FeatureItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _FeatureItem({required this.label, required this.icon, required this.color});

  @override
  State<_FeatureItem> createState() => _FeatureItemState();
}

class _FeatureItemState extends State<_FeatureItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        transform: Matrix4.translationValues(_hovered ? 4 : 0, 0, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? widget.color.withOpacity(0.3)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, size: 18, color: widget.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(widget.label,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF4ADE80).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, size: 13, color: Color(0xFF4ADE80)),
            ),
          ],
        ),
      ),
    );
  }
}