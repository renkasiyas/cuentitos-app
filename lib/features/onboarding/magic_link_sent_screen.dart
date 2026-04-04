import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/auth/auth_provider.dart';
import '../../theme/app_theme.dart';

class MagicLinkSentScreen extends ConsumerStatefulWidget {
  final String email;

  const MagicLinkSentScreen({super.key, required this.email});

  @override
  ConsumerState<MagicLinkSentScreen> createState() =>
      _MagicLinkSentScreenState();
}

class _MagicLinkSentScreenState extends ConsumerState<MagicLinkSentScreen>
    with TickerProviderStateMixin {
  static const _countdownSeconds = 60;
  int _secondsLeft = _countdownSeconds;
  Timer? _timer;
  bool _resending = false;
  String? _resendMessage;

  // Entrance animations
  late AnimationController _fadeController;
  late Animation<double> _iconFade;
  late Animation<double> _titleFade;
  late Animation<double> _bodyFade;
  late Animation<double> _timerFade;

  // Envelope pulse glow
  late AnimationController _pulseController;

  // Shimmer
  late AnimationController _shimmerController;

  // Stars
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    // Staggered entrance
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _iconFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _titleFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
    );
    _bodyFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
    );
    _timerFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );
    _fadeController.forward();

    // Slow pulse on envelope
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // Shimmer on headline
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Star controller (drives entrance; stars self-animate)
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _starController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _countdownSeconds;
      _resendMessage = null;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _resendMessage = null;
    });
    final success =
        await ref.read(userStateProvider.notifier).loginWithEmail(widget.email);
    if (!mounted) return;
    setState(() => _resending = false);
    if (success) {
      _startCountdown();
      setState(() => _resendMessage = 'Enlace reenviado.');
    } else {
      setState(() => _resendMessage = 'No pudimos reenviar. Intenta de nuevo.');
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
                  Color(0xFF060810),
                  AppColors.skyDeep,
                  Color(0xFF0D1229),
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // Lavender atmospheric glow top-left
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.lavender.withAlpha(15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Gold atmospheric glow top-right
          Positioned(
            top: size.height * 0.04,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withAlpha(12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Star field — 10 twinkling stars upper half
          ..._buildStarField(size),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Back arrow
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppColors.cream.withAlpha(153),
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),

                        // Animated envelope icon with pulse glow
                        FadeTransition(
                          opacity: _iconFade,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.25),
                              end: Offset.zero,
                            ).animate(_iconFade),
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                final t = Curves.easeInOut
                                    .transform(_pulseController.value);
                                final glowRadius = 24.0 + t * 16.0;
                                final glowAlpha = (20 + t * 35).round();
                                return Container(
                                  width: 108,
                                  height: 108,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.nightBlue,
                                    border: Border.all(
                                      color: AppColors.gold.withAlpha(
                                          (40 + t * 60).round()),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            AppColors.gold.withAlpha(glowAlpha),
                                        blurRadius: glowRadius,
                                        spreadRadius: 2,
                                      ),
                                      BoxShadow(
                                        color: AppColors.goldLight
                                            .withAlpha((glowAlpha ~/ 3)),
                                        blurRadius: glowRadius * 1.8,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: child,
                                );
                              },
                              child: const Icon(
                                Icons.mail_outline_rounded,
                                size: 52,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // "Revisa tu correo" headline with shimmer
                        FadeTransition(
                          opacity: _titleFade,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.15),
                              end: Offset.zero,
                            ).animate(_titleFade),
                            child: AnimatedBuilder(
                              animation: _shimmerController,
                              builder: (context, _) {
                                final shift =
                                    _shimmerController.value * 4 - 1;
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
                                    'Revisa tu correo',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.fraunces(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Body copy + highlighted email
                        FadeTransition(
                          opacity: _bodyFade,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.15),
                              end: Offset.zero,
                            ).animate(_bodyFade),
                            child: Column(
                              children: [
                                Text(
                                  'Enviamos un enlace mágico a',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.cream.withAlpha(153),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Gold-highlighted email pill
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withAlpha(18),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: AppColors.gold.withAlpha(50),
                                    ),
                                  ),
                                  child: Text(
                                    widget.email,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunito(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.goldLight,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Toca el enlace en tu correo para continuar.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: AppColors.cream.withAlpha(115),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 44),

                        // Countdown / resend section
                        FadeTransition(
                          opacity: _timerFade,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.15),
                              end: Offset.zero,
                            ).animate(_timerFade),
                            child: _secondsLeft > 0
                                ? _CountdownWidget(secondsLeft: _secondsLeft)
                                : _resending
                                    ? SizedBox(
                                        height: 48,
                                        width: 48,
                                        child: CircularProgressIndicator(
                                          color: AppColors.gold,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: _resend,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 28, vertical: 14),
                                          decoration: BoxDecoration(
                                            color: AppColors.gold.withAlpha(18),
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            border: Border.all(
                                              color:
                                                  AppColors.gold.withAlpha(70),
                                            ),
                                          ),
                                          child: Text(
                                            'Reenviar enlace',
                                            style: GoogleFonts.nunito(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.gold,
                                            ),
                                          ),
                                        ),
                                      ),
                          ),
                        ),

                        // Resend feedback message
                        if (_resendMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: (_resendMessage == 'Enlace reenviado.'
                                      ? AppColors.sage
                                      : AppColors.terracotta)
                                  .withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: (_resendMessage == 'Enlace reenviado.'
                                        ? AppColors.sage
                                        : AppColors.terracotta)
                                    .withAlpha(60),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _resendMessage == 'Enlace reenviado.'
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.error_outline_rounded,
                                  size: 16,
                                  color: (_resendMessage == 'Enlace reenviado.'
                                          ? AppColors.sage
                                          : AppColors.terracotta)
                                      .withAlpha(200),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _resendMessage!,
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: (_resendMessage == 'Enlace reenviado.'
                                            ? AppColors.sage
                                            : AppColors.terracotta)
                                        .withAlpha(220),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStarField(Size size) {
    final rand = math.Random(31);
    final stars = <Widget>[];
    for (int i = 0; i < 10; i++) {
      final top = rand.nextDouble() * size.height * 0.48;
      final left = rand.nextDouble() * size.width;
      final delay = rand.nextDouble() * 3.0;
      final duration = 2.8 + rand.nextDouble() * 2.4;
      final starSize = i < 2 ? 3.5 : (i < 5 ? 2.5 : 1.8);
      final isGold = i < 4;
      stars.add(
        Positioned(
          top: top,
          left: left,
          child: _TwinklingStar(
            size: starSize,
            delay: delay,
            duration: duration,
            color: isGold ? AppColors.goldLight : AppColors.cream,
            hasGlow: i < 2,
          ),
        ),
      );
    }
    return stars;
  }
}

// ─── Countdown Widget ────────────────────────────────────────────

class _CountdownWidget extends StatelessWidget {
  final int secondsLeft;

  const _CountdownWidget({required this.secondsLeft});

  @override
  Widget build(BuildContext context) {
    // Progress 1.0 → 0.0 as timer counts down
    final progress = secondsLeft / 60.0;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Track ring
            SizedBox(
              width: 72,
              height: 72,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 3,
                color: AppColors.cream.withAlpha(15),
              ),
            ),
            // Gold progress ring
            SizedBox(
              width: 72,
              height: 72,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                color: AppColors.gold,
                strokeCap: StrokeCap.round,
              ),
            ),
            // Countdown number
            Text(
              '$secondsLeft',
              style: GoogleFonts.fraunces(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.goldLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Reenviar en ${secondsLeft}s',
          style: GoogleFonts.nunito(
            fontSize: 13,
            color: AppColors.cream.withAlpha(102),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
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
