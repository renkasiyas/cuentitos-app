import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _shimmerController;
  late AnimationController _shootingStarController;
  late Animation<double> _titleFade;
  late Animation<double> _subtitleFade;
  late Animation<double> _buttonFade;

  // Mexican children's names that rotate
  static const _names = [
    'Sofia', 'Mateo', 'Valentina', 'Santiago', 'Regina',
    'Diego', 'Ximena', 'Emiliano', 'Renata', 'Sebastian',
    'Camila', 'Leonardo', 'Maria Jose', 'Daniel', 'Isabella',
    'Nicolas', 'Fernanda', 'Alejandro', 'Lucia', 'Miguel',
  ];
  int _nameIndex = 0;
  late AnimationController _nameController;
  late Animation<double> _nameFade;

  @override
  void initState() {
    super.initState();

    // Staggered entrance animations
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    _titleFade = CurvedAnimation(parent: _fadeController, curve: const Interval(0.15, 0.5, curve: Curves.easeOut));
    _subtitleFade = CurvedAnimation(parent: _fadeController, curve: const Interval(0.35, 0.65, curve: Curves.easeOut));
    _buttonFade = CurvedAnimation(parent: _fadeController, curve: const Interval(0.55, 0.85, curve: Curves.easeOut));
    _fadeController.forward();

    // Gentle floating for the moon
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);

    // Shimmer on title text
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

    // Shooting star
    _shootingStarController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

    // Name rotator
    _nameController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _nameFade = CurvedAnimation(parent: _nameController, curve: Curves.easeInOut);
    _nameController.forward();
    _startNameRotation();
  }

  void _startNameRotation() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      _nameController.reverse().then((_) {
        if (!mounted) return;
        setState(() => _nameIndex = (_nameIndex + 1) % _names.length);
        _nameController.forward();
        _startNameRotation();
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    _shootingStarController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Night sky gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF060810), AppColors.skyDeep, Color(0xFF0D1229)],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // Warm glow behind moon area
          Positioned(
            top: size.height * 0.08,
            right: size.width * 0.05,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withAlpha(20),
                    AppColors.gold.withAlpha(5),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Terracotta glow bottom-left
          Positioned(
            bottom: size.height * 0.15,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.terracotta.withAlpha(12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Star field — 30 twinkling stars
          ..._buildStarField(size),

          // Shooting star
          AnimatedBuilder(
            animation: _shootingStarController,
            builder: (context, _) {
              final progress = _shootingStarController.value;
              // Only visible for a brief window
              final visible = progress > 0.6 && progress < 0.85;
              if (!visible) return const SizedBox.shrink();
              final localProgress = (progress - 0.6) / 0.25;
              return Positioned(
                top: size.height * 0.12 + (localProgress * size.height * 0.15),
                left: size.width * (0.1 + localProgress * 0.7),
                child: Transform.rotate(
                  angle: -0.5,
                  child: Opacity(
                    opacity: (1 - localProgress).clamp(0.0, 1.0) * 0.8,
                    child: Container(
                      width: 60 + localProgress * 40,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.goldLight.withAlpha(200),
                            AppColors.cream,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Floating crescent moon
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              final float = math.sin(_floatController.value * math.pi) * 8;
              final tilt = math.sin(_floatController.value * math.pi * 2) * 0.02;
              return Positioned(
                top: size.height * 0.10 + float,
                right: size.width * 0.08,
                child: Transform.rotate(
                  angle: tilt,
                  child: child,
                ),
              );
            },
            child: _CrescentMoon(),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.32),

                  // Title with shimmer
                  FadeTransition(
                    opacity: _titleFade,
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, _) {
                        return ShaderMask(
                          shaderCallback: (bounds) {
                            final shift = _shimmerController.value * 4 - 1;
                            return LinearGradient(
                              colors: const [AppColors.cream, AppColors.goldLight, AppColors.cream],
                              stops: const [0.0, 0.5, 1.0],
                              begin: Alignment(shift - 1, 0),
                              end: Alignment(shift + 1, 0),
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            'Cuentitos',
                            style: GoogleFonts.fraunces(
                              fontSize: 52,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                              letterSpacing: -1,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Subtitle with name rotator
                  FadeTransition(
                    opacity: _subtitleFade,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cuentos de buenas noches',
                          style: GoogleFonts.nunito(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: AppColors.cream.withAlpha(179),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'para ',
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: AppColors.cream.withAlpha(179),
                              ),
                            ),
                            FadeTransition(
                              opacity: _nameFade,
                              child: Text(
                                _names[_nameIndex],
                                style: GoogleFonts.fraunces(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Feature pills
                  FadeTransition(
                    opacity: _subtitleFade,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _FeaturePill(icon: Icons.auto_stories_rounded, label: 'Personalizados'),
                        _FeaturePill(icon: Icons.headphones_rounded, label: 'Con audio'),
                        _FeaturePill(icon: Icons.nights_stay_rounded, label: 'Cada noche'),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Gold gradient CTA button
                  FadeTransition(
                    opacity: _buttonFade,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(_buttonFade),
                      child: _GoldButton(
                        text: 'Comenzar',
                        onPressed: () => context.go('/login'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Secondary link
                  FadeTransition(
                    opacity: _buttonFade,
                    child: Center(
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(
                          'Ya tengo cuenta',
                          style: GoogleFonts.nunito(
                            color: AppColors.cream.withAlpha(102),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStarField(Size size) {
    final rand = math.Random(42); // Fixed seed for deterministic placement
    final stars = <Widget>[];
    for (int i = 0; i < 30; i++) {
      final top = rand.nextDouble() * size.height * 0.6;
      final left = rand.nextDouble() * size.width;
      final delay = rand.nextDouble() * 3.2;
      final duration = 3.1 + rand.nextDouble() * 2.1;
      final starSize = i < 5 ? 4.0 : (i < 12 ? 3.0 : 2.0);
      final isGold = i < 8;
      stars.add(
        Positioned(
          top: top,
          left: left,
          child: _TwinklingStar(
            size: starSize,
            delay: delay,
            duration: duration,
            color: isGold ? AppColors.goldLight : AppColors.cream,
            hasGlow: i < 5,
          ),
        ),
      );
    }
    return stars;
  }
}

// ─── Twinkling Star ─────────────────────────────────────────────

class _TwinklingStar extends StatefulWidget {
  final double size;
  final double delay;
  final double duration;
  final Color color;
  final bool hasGlow;

  const _TwinklingStar({
    required this.size,
    required this.delay,
    required this.duration,
    required this.color,
    this.hasGlow = false,
  });

  @override
  State<_TwinklingStar> createState() => _TwinklingStarState();
}

class _TwinklingStarState extends State<_TwinklingStar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.duration * 1000).round()),
    );
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        final opacity = 0.1 + t * 0.9;
        final scale = 0.8 + t * 0.6;
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: widget.hasGlow
                    ? [BoxShadow(color: AppColors.gold.withAlpha(102), blurRadius: 6, spreadRadius: 1)]
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Crescent Moon ──────────────────────────────────────────────

class _CrescentMoon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(painter: _MoonPainter()),
    );
  }
}

class _MoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Moon body — warm gold
    final moonPaint = Paint()..color = const Color(0xFFF5A623);
    canvas.drawCircle(center, radius, moonPaint);

    // Crescent cutout — sky color to create crescent shape
    final cutoutPaint = Paint()..color = const Color(0xFF060810);
    canvas.drawCircle(Offset(center.dx + radius * 0.35, center.dy - radius * 0.15), radius * 0.82, cutoutPaint);

    // Subtle inner glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD275).withAlpha(40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(center.dx - radius * 0.2, center.dy + radius * 0.1), radius * 0.6, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Gold Gradient Button ───────────────────────────────────────

class _GoldButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const _GoldButton({required this.text, required this.onPressed});

  @override
  State<_GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<_GoldButton> with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        transform: Matrix4.diagonal3Values(
          _pressed ? 0.98 : 1.0, _pressed ? 0.98 : 1.0, 1.0)
          ..setTranslationRaw(0.0, _pressed ? -1.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5A623), Color(0xFFE89B1C)],
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withAlpha(_pressed ? 50 : 77),
              blurRadius: _pressed ? 16 : 24,
              offset: Offset(0, _pressed ? 2 : 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.skyDeep,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Feature Pill ───────────────────────────────────────────────

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cream.withAlpha(10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.cream.withAlpha(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.goldLight.withAlpha(179)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.cream.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }
}
