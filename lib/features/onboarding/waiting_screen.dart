import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/sync/sync_provider.dart';
import '../../theme/app_theme.dart';

class WaitingScreen extends ConsumerStatefulWidget {
  const WaitingScreen({super.key});

  @override
  ConsumerState<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen>
    with TickerProviderStateMixin {
  Timer? _pollTimer;
  bool _syncing = false;

  // Entrance animations
  late AnimationController _fadeController;
  late Animation<double> _magicFade;
  late Animation<double> _titleFade;
  late Animation<double> _subtitleFade;

  // Shimmer on title
  late AnimationController _shimmerController;

  // The three golden orbs orbit controller
  late AnimationController _orbitController;

  // Central star pulse
  late AnimationController _pulseController;

  // Particle rise
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _startPolling();

    // Staggered entrance
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _magicFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _titleFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
    );
    _subtitleFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );
    _fadeController.forward();

    // Shimmer on headline
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Orbit controller — three golden orbs rotating around a center
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    // Central star pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Rising particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _fadeController.dispose();
    _shimmerController.dispose();
    _orbitController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _poll();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
  }

  Future<void> _poll() async {
    if (_syncing) return;
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get(
        Endpoints.stories,
        queryParameters: {'limit': '1'},
      );
      final stories = response.data['stories'] as List<dynamic>?;
      if (stories != null && stories.isNotEmpty) {
        final story = stories.first as Map<String, dynamic>;
        if (story['generationStatus'] == 'generated') {
          _pollTimer?.cancel();
          setState(() => _syncing = true);
          await ref.read(syncProvider).fullSync();
          await ref.read(userStateProvider.notifier).refreshState();
          if (mounted) context.go('/tonight');
        }
      }
    } catch (_) {
      // Silently retry on next tick
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Night sky gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF050710),
                  AppColors.skyDeep,
                  Color(0xFF0C1128),
                  Color(0xFF0A0F22),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Atmospheric gold glow around center
          Positioned(
            top: size.height * 0.25,
            left: size.width * 0.5 - 140,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withAlpha(14),
                    AppColors.gold.withAlpha(5),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Lavender glow top-left
          Positioned(
            top: -40,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.lavender.withAlpha(14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Terracotta glow bottom-right
          Positioned(
            bottom: size.height * 0.1,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.terracotta.withAlpha(10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Star field — 22 stars spread across full screen
          ..._buildStarField(size),

          // Main content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.05),

                    // Magic loading animation — orbiting golden orbs
                    FadeTransition(
                      opacity: _magicFade,
                      child: _OrbitalMagic(
                        orbitController: _orbitController,
                        pulseController: _pulseController,
                        particleController: _particleController,
                      ),
                    ),

                    SizedBox(height: size.height * 0.07),

                    // "Preparando tu primer cuento..." with shimmer
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(_titleFade),
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, _) {
                            final shift = _shimmerController.value * 4 - 1;
                            return ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: const [
                                    AppColors.cream,
                                    AppColors.goldLight,
                                    AppColors.cream,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                  begin: Alignment(shift - 1, 0),
                                  end: Alignment(shift + 1, 0),
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                'Preparando tu\nprimer cuento...',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fraunces(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    FadeTransition(
                      opacity: _subtitleFade,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(_subtitleFade),
                        child: Text(
                          'Esto toma menos de un minuto',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            color: AppColors.cream.withAlpha(128),
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Secondary hint
                    FadeTransition(
                      opacity: _subtitleFade,
                      child: Text(
                        'Estamos tejiendo una historia única\npara tu pequeño explorador',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: AppColors.cream.withAlpha(76),
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.05),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStarField(Size size) {
    final rand = math.Random(77);
    final stars = <Widget>[];
    for (int i = 0; i < 22; i++) {
      // Spread across full screen height, denser toward top
      final topFraction = i < 14
          ? rand.nextDouble() * 0.55
          : 0.55 + rand.nextDouble() * 0.38;
      final top = topFraction * size.height;
      final left = rand.nextDouble() * size.width;
      final delay = rand.nextDouble() * 3.5;
      final duration = 2.5 + rand.nextDouble() * 2.8;
      final starSize = i < 4 ? 4.0 : (i < 10 ? 3.0 : 2.0);
      final isGold = i < 9;
      stars.add(
        Positioned(
          top: top,
          left: left,
          child: _TwinklingStar(
            size: starSize,
            delay: delay,
            duration: duration,
            color: isGold ? AppColors.goldLight : AppColors.cream,
            hasGlow: i < 4,
          ),
        ),
      );
    }
    return stars;
  }
}

// ─── Orbital Magic Animation ─────────────────────────────────────

class _OrbitalMagic extends StatelessWidget {
  final AnimationController orbitController;
  final AnimationController pulseController;
  final AnimationController particleController;

  static const double _canvasSize = 160.0;
  static const double _orbitRadius = 54.0;
  static const double _orbSize = 14.0;
  static const double _centerSize = 22.0;

  const _OrbitalMagic({
    required this.orbitController,
    required this.pulseController,
    required this.particleController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _canvasSize,
      height: _canvasSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rising particles (behind orbit)
          AnimatedBuilder(
            animation: particleController,
            builder: (context, _) {
              return CustomPaint(
                size: const Size(_canvasSize, _canvasSize),
                painter: _ParticlePainter(progress: particleController.value),
              );
            },
          ),

          // Orbit trail ring
          Container(
            width: _orbitRadius * 2 + _orbSize,
            height: _orbitRadius * 2 + _orbSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.gold.withAlpha(18),
                width: 1,
              ),
            ),
          ),

          // Three orbiting orbs
          AnimatedBuilder(
            animation: orbitController,
            builder: (context, _) {
              final angle = orbitController.value * 2 * math.pi;
              return Stack(
                alignment: Alignment.center,
                children: List.generate(3, (i) {
                  final orbAngle = angle + (i * 2 * math.pi / 3);
                  final x = math.cos(orbAngle) * _orbitRadius;
                  final y = math.sin(orbAngle) * _orbitRadius;

                  // Each orb has a slightly different brightness
                  final brightness = i == 0 ? 1.0 : (i == 1 ? 0.75 : 0.55);

                  return Transform.translate(
                    offset: Offset(x, y),
                    child: Container(
                      width: _orbSize - i * 1.5,
                      height: _orbSize - i * 1.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.goldLight.withAlpha(
                                (255 * brightness).round()),
                            AppColors.gold.withAlpha(
                                (200 * brightness).round()),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold
                                .withAlpha((120 * brightness).round()),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: AppColors.goldLight
                                .withAlpha((60 * brightness).round()),
                            blurRadius: 18,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          // Central pulsing star
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(pulseController.value);
              final glowAlpha = (30 + t * 55).round();
              final scale = 0.88 + t * 0.24;

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: _centerSize,
                  height: _centerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        AppColors.goldLight,
                        AppColors.gold,
                        Color(0xFFE89B1C),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withAlpha(glowAlpha + 40),
                        blurRadius: 14 + t * 10,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: AppColors.goldLight.withAlpha(glowAlpha),
                        blurRadius: 28 + t * 16,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _StarPainter(color: AppColors.skyDeep),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Rising Particles Painter ────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final double progress;

  // Fixed particle seeds for deterministic layout
  static final _seeds = List.generate(
      8, (i) => (i * 137.508 + 42.0) % 360.0); // golden angle spread

  _ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rand = math.Random(99);

    for (int i = 0; i < 8; i++) {
      // Stagger particle phases
      final phase = (progress + i / 8.0) % 1.0;
      if (phase < 0.05 || phase > 0.95) continue; // fade at edges

      final angle = _seeds[i] * math.pi / 180.0;
      // Start near orbit radius, drift outward and upward
      final startRadius = 50.0 + rand.nextDouble() * 20;
      final endRadius = startRadius + 30 + rand.nextDouble() * 25;
      final r = startRadius + (endRadius - startRadius) * phase;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r - phase * 40;

      final opacity =
          (phase < 0.2 ? phase / 0.2 : (1.0 - phase) / 0.8).clamp(0.0, 1.0);
      final particleSize = 1.5 + rand.nextDouble() * 1.5;

      final paint = Paint()
        ..color = (i % 3 == 0 ? AppColors.goldLight : AppColors.gold)
            .withAlpha((opacity * 180).round())
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particleSize * (1 - phase * 0.3), paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

// ─── 4-Point Star Painter ────────────────────────────────────────

class _StarPainter extends CustomPainter {
  final Color color;

  const _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha(160)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width * 0.38;
    final inner = size.width * 0.14;

    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - math.pi / 2;
      final r = i.isEven ? outer : inner;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Twinkling Star ──────────────────────────────────────────────

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

class _TwinklingStarState extends State<_TwinklingStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.duration * 1000).round()),
    );
    Future.delayed(
      Duration(milliseconds: (widget.delay * 1000).round()),
      () {
        if (mounted) _controller.repeat(reverse: true);
      },
    );
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
        final scale = 0.8 + t * 0.5;
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
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withAlpha(100),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
