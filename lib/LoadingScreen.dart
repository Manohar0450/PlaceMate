import 'package:flutter/material.dart';
import 'dart:math' as math;

class LoadingScreen extends StatefulWidget {
  final String message;
  const LoadingScreen({super.key, this.message = 'Loading...'});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  late AnimationController _ring1Ctrl;
  late AnimationController _ring2Ctrl;
  late AnimationController _ring3Ctrl;
  late AnimationController _glowCtrl;
  late AnimationController _dotsCtrl;
  late AnimationController _dialogCtrl;

  late Animation<double> _glow;
  late Animation<double> _dialogScale;
  late Animation<double> _dialogFade;

  @override
  void initState() {
    super.initState();

    _ring1Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _ring2Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: false);
    _ring3Ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _dotsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

    _dialogCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _glow = Tween<double>(begin: 0.06, end: 0.14)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _dialogScale = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _dialogCtrl, curve: Curves.easeOutBack));
    _dialogFade = CurvedAnimation(parent: _dialogCtrl, curve: Curves.easeOut);

    _dialogCtrl.forward();
  }

  @override
  void dispose() {
    _ring1Ctrl.dispose();
    _ring2Ctrl.dispose();
    _ring3Ctrl.dispose();
    _glowCtrl.dispose();
    _dotsCtrl.dispose();
    _dialogCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFC9A84C);

    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: FadeTransition(
            opacity: _dialogFade,
            child: ScaleTransition(
              scale: _dialogScale,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF13131A), Color(0xFF0D0D0F)],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: gold.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(0.12),
                      blurRadius: 48,
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Triple Spinner ---
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ring 1 (outer)
                          AnimatedBuilder(
                            animation: _ring1Ctrl,
                            builder: (_, __) => Transform.rotate(
                              angle: _ring1Ctrl.value * 2 * math.pi,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: CustomPaint(painter: _ArcPainter(gold, 1.0)),
                              ),
                            ),
                          ),
                          // Ring 2 (middle, reverse)
                          AnimatedBuilder(
                            animation: _ring2Ctrl,
                            builder: (_, __) => Transform.rotate(
                              angle: -_ring2Ctrl.value * 2 * math.pi,
                              child: SizedBox(
                                width: 68,
                                height: 68,
                                child: CustomPaint(
                                    painter: _ArcPainter(gold.withOpacity(0.45), 0.6)),
                              ),
                            ),
                          ),
                          // Ring 3 (inner)
                          AnimatedBuilder(
                            animation: _ring3Ctrl,
                            builder: (_, __) => Transform.rotate(
                              angle: _ring3Ctrl.value * 2 * math.pi,
                              child: SizedBox(
                                width: 46,
                                height: 46,
                                child: CustomPaint(
                                    painter: _ArcPainter(gold.withOpacity(0.2), 0.4)),
                              ),
                            ),
                          ),
                          // Center icon
                          AnimatedBuilder(
                            animation: _glowCtrl,
                            builder: (_, child) => Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: gold.withOpacity(_glow.value),
                                shape: BoxShape.circle,
                                border: Border.all(color: gold.withOpacity(0.35)),
                              ),
                              child: const Icon(Icons.business_center_rounded,
                                  size: 14, color: gold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Message ---
                    Text(
                      widget.message,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Please wait a moment",
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.4)),
                    ),
                    const SizedBox(height: 20),

                    // --- Animated Dots ---
                    _AnimatedDots(controller: _dotsCtrl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  final double arcFraction;
  const _ArcPainter(this.color, this.arcFraction);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * arcFraction, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color || old.arcFraction != arcFraction;
}

class _AnimatedDots extends StatelessWidget {
  final AnimationController controller;
  const _AnimatedDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final phase = ((controller.value * 3 - i) % 3);
            final opacity = phase < 1
                ? 0.3 + phase * 0.7
                : phase < 2
                ? 1.0 - (phase - 1) * 0.7
                : 0.3;
            return Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFC9A84C).withOpacity(opacity.clamp(0.3, 1.0)),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}