import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../db/database.dart';
import '../../providers/stories_provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/download_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../theme/app_theme.dart';
import '../reader/tts_stripper.dart';

class TonightScreen extends ConsumerWidget {
  const TonightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(isActiveSubscriberProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final storyAsync = ref.watch(todayStoryProvider);
    final parentAsync = ref.watch(parentProfileProvider);
    final isOnline = ref.watch(connectivityProvider).value ?? true;

    return Scaffold(
      backgroundColor: AppColors.skyDeep,
      body: Stack(
        children: [
          // Night sky gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF060810), AppColors.skyDeep, Color(0xFF0D1229)],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // Warm gold glow in upper area
          Positioned(
            top: -40,
            right: -20,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withAlpha(18),
                    AppColors.gold.withAlpha(5),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Scattered background stars
          ..._buildStarField(context),

          // Full screen content
          SafeArea(
            child: Column(
              children: [
                // Offline banner
                if (!isOnline)
                  Container(
                    width: double.infinity,
                    color: AppColors.warning.withAlpha(200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Sin conexion',
                      style: GoogleFonts.nunito(
                        color: AppColors.skyDeep,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Custom app bar area
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        'Esta noche',
                        style: GoogleFonts.fraunces(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cream,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildBody(context, ref, isActive, isPremium, storyAsync, parentAsync),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStarField(BuildContext context) {
    final rand = math.Random(99);
    final stars = <Widget>[];
    final size = MediaQuery.of(context).size;
    for (int i = 0; i < 7; i++) {
      final top = rand.nextDouble() * size.height * 0.55;
      final left = rand.nextDouble() * size.width;
      final delay = rand.nextDouble() * 3.0;
      final duration = 3.0 + rand.nextDouble() * 2.0;
      final starSize = i < 2 ? 3.5 : 2.0;
      final isGold = i < 3;
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

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    bool isActive,
    bool isPremium,
    AsyncValue<Story?> storyAsync,
    AsyncValue<dynamic> parentAsync,
  ) {
    if (!isActive) {
      return _NotSubscribedState(onSubscribe: () => context.push('/tier', extra: <String, dynamic>{}));
    }

    return storyAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
      error: (e, _) => Center(
        child: Text(
          'Error: $e',
          style: GoogleFonts.nunito(color: AppColors.cream.withAlpha(179)),
        ),
      ),
      data: (story) {
        if (story == null || story.generationStatus == 'pending') {
          final deliveryHour = parentAsync.value?.deliveryHour ?? 18;
          return _PendingState(deliveryHour: deliveryHour);
        }
        if (story.generationStatus == 'generating') {
          return const _GeneratingState();
        }
        if (story.generationStatus == 'failed') {
          return const _FailedState();
        }
        return _StoryCard(story: story, isPremium: isPremium, ref: ref);
      },
    );
  }
}

// ─── Star helper (shared with onboarding aesthetic) ───────────────────────────

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
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.duration * 1000).round()),
    );
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        return Transform.scale(
          scale: 0.8 + t * 0.6,
          child: Opacity(
            opacity: 0.1 + t * 0.9,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: widget.hasGlow
                    ? [BoxShadow(color: AppColors.gold.withAlpha(100), blurRadius: 6, spreadRadius: 1)]
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Crescent moon CustomPaint ────────────────────────────────────────────────

class _CrescentMoon extends StatelessWidget {
  final double size;
  final Color skyColor;
  const _CrescentMoon({this.size = 80, this.skyColor = const Color(0xFF060810)});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MoonPainter(skyColor: skyColor)),
    );
  }
}

class _MoonPainter extends CustomPainter {
  final Color skyColor;
  const _MoonPainter({required this.skyColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final moonPaint = Paint()..color = AppColors.gold;
    canvas.drawCircle(center, radius, moonPaint);

    final cutoutPaint = Paint()..color = skyColor;
    canvas.drawCircle(
      Offset(center.dx + radius * 0.35, center.dy - radius * 0.15),
      radius * 0.82,
      cutoutPaint,
    );

    final glowPaint = Paint()
      ..color = AppColors.goldLight.withAlpha(40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
      Offset(center.dx - radius * 0.2, center.dy + radius * 0.1),
      radius * 0.6,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MoonPainter old) => old.skyColor != skyColor;
}

// ─── Not subscribed ───────────────────────────────────────────────────────────

class _NotSubscribedState extends StatefulWidget {
  final VoidCallback onSubscribe;
  const _NotSubscribedState({required this.onSubscribe});

  @override
  State<_NotSubscribedState> createState() => _NotSubscribedStateState();
}

class _NotSubscribedStateState extends State<_NotSubscribedState>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _CrescentMoon(size: 80, skyColor: Color(0xFF060810)),
              const SizedBox(height: 32),
              Text(
                'Suscribete para recibir cuentos',
                style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream,
                  height: 1.25,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Cuentos personalizados cada noche para tu hijo',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: AppColors.cream.withAlpha(153),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: widget.onSubscribe,
                child: const Text('Ver planes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Pending ──────────────────────────────────────────────────────────────────

class _PendingState extends StatefulWidget {
  final int deliveryHour;
  const _PendingState({required this.deliveryHour});

  @override
  State<_PendingState> createState() => _PendingStateState();
}

class _PendingStateState extends State<_PendingState> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h:00 $period';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _CrescentMoon(size: 80, skyColor: Color(0xFF060810)),
              const SizedBox(height: 32),
              Text(
                'Tu cuento llega a las\n${_formatHour(widget.deliveryHour)}',
                style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Vuelve esta noche para leerlo juntos',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: AppColors.cream.withAlpha(153),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Generating ──────────────────────────────────────────────────────────────

class _GeneratingState extends StatelessWidget {
  const _GeneratingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: AppColors.gold,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Tu cuento se esta preparando...',
            style: GoogleFonts.fraunces(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.cream,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Esto toma solo un momento',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.cream.withAlpha(153),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Failed ──────────────────────────────────────────────────────────────────

class _FailedState extends StatelessWidget {
  const _FailedState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied_outlined,
            size: 64,
            color: AppColors.gold.withAlpha(180),
          ),
          const SizedBox(height: 24),
          Text(
            'Hubo un problema.',
            style: GoogleFonts.fraunces(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.cream,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tu cuento llegara pronto.',
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: AppColors.cream.withAlpha(153),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Story card ───────────────────────────────────────────────────────────────

class _StoryCard extends StatefulWidget {
  final Story story;
  final bool isPremium;
  final WidgetRef ref;

  const _StoryCard({required this.story, required this.isPremium, required this.ref});

  @override
  State<_StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<_StoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<String> _parseTags(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    return raw
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final tags = _parseTags(story.themeTags);
    final rawBody = story.bodyText ?? '';
    final preview = stripTtsTags(rawBody.length > 200 ? rawBody.substring(0, 200) : rawBody);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero card with gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.skyDeep, Color(0xFF060810)],
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(
                    color: AppColors.gold.withAlpha(40),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withAlpha(20),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Theme tag pills
                    if (tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.goldDim,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  tag,
                                  style: GoogleFonts.nunito(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.goldLight,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    if (tags.isNotEmpty) const SizedBox(height: 16),

                    // Title in Fraunces
                    Text(
                      story.title ?? '',
                      style: GoogleFonts.fraunces(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cream,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Body preview
                    Text(
                      '$preview...',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.cream.withAlpha(204),
                        height: 1.7,
                      ),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Read button
              ElevatedButton(
                onPressed: () => context.push('/reader/${story.id}'),
                child: const Text('Leer cuento'),
              ),

              const SizedBox(height: 12),

              // Listen button (premium + audio)
              if (widget.isPremium && story.audioUrl != null)
                OutlinedButton.icon(
                  onPressed: () => context.push('/reader/${story.id}'),
                  icon: const Icon(Icons.headphones),
                  label: const Text('Escuchar cuento'),
                ),

              const SizedBox(height: 8),

              // Download button
              _DownloadButton(story: story, ref: widget.ref),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Download button ──────────────────────────────────────────────────────────

class _DownloadButton extends StatelessWidget {
  final Story story;
  final WidgetRef ref;

  const _DownloadButton({required this.story, required this.ref});

  @override
  Widget build(BuildContext context) {
    final downloadState = ref.watch(downloadProvider);
    final status = downloadState.statusFor(story.id);

    switch (status) {
      case DownloadStatus.idle:
        return TextButton.icon(
          onPressed: () => ref.read(downloadProvider.notifier).download(story.id),
          icon: const Icon(Icons.cloud_download),
          label: const Text('Descargar para leer sin conexion'),
        );

      case DownloadStatus.downloading:
        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
          ),
        );

      case DownloadStatus.done:
        return TextButton.icon(
          onPressed: null,
          icon: const Icon(Icons.check_circle, color: AppColors.success),
          label: const Text('Descargado', style: TextStyle(color: AppColors.success)),
        );

      case DownloadStatus.error:
        return TextButton.icon(
          onPressed: () => ref.read(downloadProvider.notifier).download(story.id),
          icon: const Icon(Icons.refresh, color: AppColors.error),
          label: const Text('Reintentar descarga', style: TextStyle(color: AppColors.error)),
        );
    }
  }
}
