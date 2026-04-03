import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/sync/sync_provider.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  bool _loadingEmail = false;
  bool _loadingGoogle = false;
  String? _error;

  late AnimationController _fadeController;
  late AnimationController _shimmerController;
  late Animation<double> _headerFade;
  late Animation<double> _fieldFade;
  late Animation<double> _buttonFade;
  late Animation<double> _dividerFade;
  late Animation<double> _googleFade;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _headerFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _fieldFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.2, 0.55, curve: Curves.easeOut),
    );
    _buttonFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    );
    _dividerFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.55, 0.8, curve: Curves.easeOut),
    );
    _googleFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );
    _fadeController.forward();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _sendMagicLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Ingresa tu correo electrónico');
      return;
    }
    setState(() {
      _loadingEmail = true;
      _error = null;
    });
    final success =
        await ref.read(authProvider.notifier).loginWithEmail(email);
    if (!mounted) return;
    setState(() => _loadingEmail = false);
    if (success) {
      context.go('/magic-link-sent?email=${Uri.encodeComponent(email)}');
    } else {
      setState(() =>
          _error = 'No pudimos enviar el enlace. Intenta de nuevo.');
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loadingGoogle = true;
      _error = null;
    });
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      final account = await googleSignIn.signIn();
      if (account == null) {
        setState(() => _loadingGoogle = false);
        return;
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        setState(() {
          _loadingGoogle = false;
          _error = 'No se pudo obtener el token de Google.';
        });
        return;
      }
      final success =
          await ref.read(authProvider.notifier).loginWithGoogle(idToken);
      if (!mounted) return;
      setState(() => _loadingGoogle = false);
      if (success) {
        try {
          final dio = ref.read(apiClientProvider);
          final response = await dio.get(Endpoints.me);
          if (!mounted) return;
          final child = response.data['child'];
          final parent = response.data['parent'] as Map<String, dynamic>?;
          final subscriptionStatus =
              parent?['subscriptionStatus'] as String?;
          if (child != null && subscriptionStatus == 'active') {
            await ref.read(syncProvider).fullSync();
            if (mounted) context.go('/tonight');
          } else {
            if (mounted) context.go('/quiz');
          }
        } catch (_) {
          if (mounted) context.go('/quiz');
        }
      } else {
        setState(() => _error =
            'No pudimos iniciar sesión con Google. Intenta de nuevo.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingGoogle = false;
        _error =
            'Google Sign-In no esta disponible. Usa tu correo electronico.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _loadingEmail || _loadingGoogle;
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

          // Lavender glow top-left (atmosphere)
          Positioned(
            top: -40,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.lavender.withAlpha(18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Gold glow top-right
          Positioned(
            top: size.height * 0.05,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withAlpha(15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Star field — 12 twinkling stars in upper half
          ..._buildStarField(size),

          // Back button + content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back button row
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: AppColors.cream.withAlpha(153),
                      size: 20,
                    ),
                    onPressed: () => context.go('/'),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),

                        // Header with shimmer
                        FadeTransition(
                          opacity: _headerFade,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(_headerFade),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedBuilder(
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
                                        'Ingresa a Cuentitos',
                                        style: GoogleFonts.fraunces(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w700,
                                          height: 1.1,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Te enviaremos un enlace mágico a tu correo.',
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.cream.withAlpha(153),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Email field with warm glow container
                        FadeTransition(
                          opacity: _fieldFade,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(_fieldFade),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withAlpha(20),
                                    blurRadius: 20,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                enabled: !isLoading,
                                style: GoogleFonts.nunito(
                                  color: AppColors.cream,
                                  fontSize: 15,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Correo electrónico',
                                  hintText: 'tu@correo.com',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: AppColors.gold.withAlpha(179),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Gold gradient magic link button
                        FadeTransition(
                          opacity: _buttonFade,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(_buttonFade),
                            child: _GoldButton(
                              loading: _loadingEmail,
                              disabled: isLoading,
                              text: 'Enviar enlace mágico',
                              onPressed: _sendMagicLink,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Divider
                        FadeTransition(
                          opacity: _dividerFade,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        AppColors.cream.withAlpha(30),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'o',
                                  style: GoogleFonts.nunito(
                                    color: AppColors.cream.withAlpha(102),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.cream.withAlpha(30),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Google button
                        FadeTransition(
                          opacity: _googleFade,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(_googleFade),
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton(
                                onPressed:
                                    isLoading ? null : _signInWithGoogle,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFAFAFA),
                                  foregroundColor: const Color(0xFF3C4043),
                                  side: const BorderSide(
                                      color: Color(0xFFDADCE0)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                ),
                                child: _loadingGoogle
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF4285F4),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/google_logo.svg',
                                            width: 20,
                                            height: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Continuar con Google',
                                            style: GoogleFonts.roboto(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF3C4043),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),

                        // Error container
                        if (_error != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.terracotta.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.terracotta.withAlpha(60),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.terracotta.withAlpha(20),
                                  blurRadius: 16,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.terracotta.withAlpha(200),
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: GoogleFonts.nunito(
                                      color:
                                          AppColors.terracotta.withAlpha(220),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
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
    final rand = math.Random(17);
    final stars = <Widget>[];
    for (int i = 0; i < 12; i++) {
      final top = rand.nextDouble() * size.height * 0.5;
      final left = rand.nextDouble() * size.width;
      final delay = rand.nextDouble() * 3.0;
      final duration = 2.8 + rand.nextDouble() * 2.2;
      final starSize = i < 3 ? 3.5 : (i < 7 ? 2.5 : 1.8);
      final isGold = i < 5;
      stars.add(
        Positioned(
          top: top,
          left: left,
          child: _TwinklingStar(
            size: starSize,
            delay: delay,
            duration: duration,
            color: isGold ? AppColors.goldLight : AppColors.cream,
            hasGlow: i < 3,
          ),
        ),
      );
    }
    return stars;
  }
}

// ─── Gold Gradient Button ────────────────────────────────────────

class _GoldButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool loading;
  final bool disabled;

  const _GoldButton({
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.disabled = false,
  });

  @override
  State<_GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<_GoldButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.disabled
          ? null
          : (_) {
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
          gradient: widget.disabled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.gold.withAlpha(120),
                    const Color(0xFFE89B1C).withAlpha(120),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF5A623), Color(0xFFE89B1C)],
                ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: widget.disabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.gold.withAlpha(_pressed ? 50 : 77),
                    blurRadius: _pressed ? 16 : 24,
                    offset: Offset(0, _pressed ? 2 : 4),
                  ),
                ],
        ),
        child: Center(
          child: widget.loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.skyDeep,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  widget.text,
                  style: GoogleFonts.nunito(
                    fontSize: 17,
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
      duration:
          Duration(milliseconds: (widget.duration * 1000).round()),
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
