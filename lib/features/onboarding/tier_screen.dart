import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class TierScreen extends StatefulWidget {
  final Map<String, dynamic> quizData;

  const TierScreen({super.key, required this.quizData});

  @override
  State<TierScreen> createState() => _TierScreenState();
}

class _TierScreenState extends State<TierScreen> with TickerProviderStateMixin {
  String _selectedTier = 'basico';
  bool _pressed = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _continue() {
    context.go('/checkout', extra: {
      ...widget.quizData,
      'tier': _selectedTier,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skyDeep,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.cream, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Elige tu plan',
          style: GoogleFonts.fraunces(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.cream,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Elige el plan perfecto\npara tu familia',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      color: AppColors.cream.withAlpha(166),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _BasicTierCard(
                    selected: _selectedTier == 'basico',
                    onTap: () => setState(() => _selectedTier = 'basico'),
                  ),
                  const SizedBox(height: 16),
                  _PremiumTierCard(
                    selected: _selectedTier == 'premium',
                    onTap: () => setState(() => _selectedTier = 'premium'),
                  ),
                  const Spacer(),
                  _buildContinueButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _continue();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        transform: Matrix4.diagonal3Values(
          _pressed ? 0.98 : 1.0,
          _pressed ? 0.98 : 1.0,
          1.0,
        )..setTranslationRaw(0.0, _pressed ? -1.0 : 0.0, 0.0),
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
            'Continuar al pago',
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

// ─── Basic Tier Card ──────────────────────────────────────────────────────────

class _BasicTierCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _BasicTierCard({required this.selected, required this.onTap});

  static const _features = [
    '1 cuento por semana',
    'Personalización básica',
    'Audio narrado por IA',
    'Biblioteca de cuentos',
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppColors.nightBlue : AppColors.nightBlue.withAlpha(200),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.gold.withAlpha(120) : AppColors.cream.withAlpha(30),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withAlpha(20),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Básico',
                  style: GoogleFonts.fraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cream,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$79',
                      style: GoogleFonts.fraunces(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cream,
                        height: 1,
                      ),
                    ),
                    Text(
                      'por mes',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.cream.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 16, color: AppColors.sage),
                      const SizedBox(width: 8),
                      Text(
                        f,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: AppColors.cream.withAlpha(179),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Premium Tier Card ────────────────────────────────────────────────────────

class _PremiumTierCard extends StatefulWidget {
  final bool selected;
  final VoidCallback onTap;

  const _PremiumTierCard({required this.selected, required this.onTap});

  @override
  State<_PremiumTierCard> createState() => _PremiumTierCardState();
}

class _PremiumTierCardState extends State<_PremiumTierCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  static const _features = [
    '3 cuentos por semana',
    'Personalización avanzada',
    'Voces premium narradas',
    'Biblioteca completa',
    'Listas de reproducción',
    'Soporte prioritario',
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          final shimmerAngle = _shimmerController.value * 2 * math.pi;
          final glowAlpha = widget.selected
              ? (100 + (55 * math.sin(shimmerAngle)).abs()).toInt()
              : 40;
          final borderAlpha = widget.selected
              ? (160 + (60 * math.sin(shimmerAngle)).abs()).toInt().clamp(0, 255)
              : 60;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.skyDeep,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.gold.withAlpha(borderAlpha),
                width: widget.selected ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withAlpha(glowAlpha),
                  blurRadius: widget.selected ? 28 : 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium',
                      style: GoogleFonts.fraunces(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Gold gradient "Más popular" badge
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF5A623), Color(0xFFE89B1C)],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withAlpha(60),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        'Más popular',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.skyDeep,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$149',
                      style: GoogleFonts.fraunces(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gold,
                        height: 1,
                      ),
                    ),
                    Text(
                      'por mes',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.gold.withAlpha(160),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 16, color: AppColors.gold),
                      const SizedBox(width: 8),
                      Text(
                        f,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: AppColors.cream.withAlpha(210),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
