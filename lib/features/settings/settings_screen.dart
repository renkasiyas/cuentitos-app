import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/init_provider.dart';
import '../../core/storage/audio_cache.dart';
import '../../providers/child_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/stories_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entranceFade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h:00 $period';
  }

  void _showDeliveryTimePicker(BuildContext context, int currentHour) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.nightBlue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _DeliveryTimePicker(
        currentHour: currentHour,
        onSelect: (hour) async {
          Navigator.pop(ctx);
          try {
            final isOnline = ref.read(connectivityProvider).value ?? false;
            if (isOnline) {
              final dio = ref.read(apiClientProvider);
              await dio.post(Endpoints.deliveryTime, data: {'hour': hour});
            } else {
              await ref
                  .read(pendingActionsProvider)
                  .enqueue('delivery_time', {'hour': hour});
            }
            ref.invalidate(parentProfileProvider);
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error al guardar la hora')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentAsync = ref.watch(parentProfileProvider);
    final childAsync = ref.watch(childProfileProvider);
    final tier = ref.watch(subscriptionTierProvider);

    return Scaffold(
      backgroundColor: AppColors.skyDeep,
      body: Stack(
        children: [
          // Night sky gradient top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF060810), AppColors.skyDeep],
                ),
              ),
            ),
          ),

          // Subtle gold glow top-right
          Positioned(
            top: -50,
            right: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withAlpha(14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          FadeTransition(
            opacity: _entranceFade,
            child: SlideTransition(
              position: _entranceSlide,
              child: SafeArea(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Custom app bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Text(
                        'Ajustes',
                        style: GoogleFonts.fraunces(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cream,
                          height: 1.1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Profile hero section ──────────────────────────────────
                    childAsync.when(
                      loading: () => const _ProfileHeroSkeleton(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (child) => _ProfileHero(
                        childName: child?.name,
                        animal: child?.favoriteAnimal,
                        color: child?.favoriteColor,
                        onTap: () => context.push('/settings/profile'),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Suscripcion ───────────────────────────────────────────
                    _SectionHeader('Suscripcion'),
                    const SizedBox(height: 8),
                    _SettingsCard(
                      children: [
                        _SettingsTile(
                          icon: Icons.star_outline_rounded,
                          label: tier == 'premium' ? 'Plan Premium' : 'Plan Basico',
                          sublabel: tier == 'premium' ? '\$99 MXN / mes' : 'Gratis',
                          onTap: () => context.push('/settings/subscription'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Hora de entrega ───────────────────────────────────────
                    _SectionHeader('Hora de entrega'),
                    const SizedBox(height: 8),
                    _SettingsCard(
                      children: [
                        parentAsync.when(
                          loading: () => const _TileLoading(),
                          error: (_, __) => const _TileError(),
                          data: (parent) {
                            final hour = parent?.deliveryHour ?? 18;
                            return _SettingsTile(
                              icon: Icons.nights_stay_outlined,
                              label: 'Hora de tu cuento',
                              sublabel: _formatHour(hour),
                              onTap: () =>
                                  _showDeliveryTimePicker(context, hour),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Almacenamiento ────────────────────────────────────────
                    _SectionHeader('Almacenamiento'),
                    const SizedBox(height: 8),
                    _StorageCard(),

                    const SizedBox(height: 20),

                    // ── Acerca de ─────────────────────────────────────────────
                    _SectionHeader('Acerca de'),
                    const SizedBox(height: 8),
                    _SettingsCard(
                      children: [
                        _SettingsTile(
                          icon: Icons.info_outline_rounded,
                          label: 'Version',
                          trailing: Text(
                            '1.0.0',
                            style: GoogleFonts.nunito(
                              color: AppColors.cream.withAlpha(128),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        _SettingsDivider(),
                        _SettingsTile(
                          icon: Icons.shield_outlined,
                          label: 'Politica de privacidad',
                          trailing: Icon(
                            Icons.open_in_new,
                            size: 16,
                            color: AppColors.cream.withAlpha(100),
                          ),
                          onTap: () {},
                        ),
                        _SettingsDivider(),
                        _SettingsTile(
                          icon: Icons.mail_outline_rounded,
                          label: 'Soporte',
                          sublabel: 'hola@cuentitos.mx',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── Logout ────────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _LogoutButton(
                        onPressed: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) context.go('/welcome');
                        },
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile hero ─────────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  final String? childName;
  final String? animal;
  final String? color;
  final VoidCallback onTap;

  const _ProfileHero({
    required this.childName,
    required this.animal,
    required this.color,
    required this.onTap,
  });

  String get _initials {
    final name = childName ?? '';
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String get _subtitle {
    final parts = [
      if (animal != null && animal!.isNotEmpty) animal,
      if (color != null && color!.isNotEmpty) color,
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.nightBlue,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withAlpha(40), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gold gradient avatar circle
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.goldLight, AppColors.gold],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withAlpha(60),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: GoogleFonts.fraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.skyDeep,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    childName ?? '—',
                    style: GoogleFonts.fraunces(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                      height: 1.2,
                    ),
                  ),
                  if (_subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.cream.withAlpha(153),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.gold.withAlpha(160),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeroSkeleton extends StatelessWidget {
  const _ProfileHeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.nightBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withAlpha(20), width: 1),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
      ),
    );
  }
}

// ─── Section header with gold underline ───────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.fraunces(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gold.withAlpha(200),
              height: 1.2,
              fontFeatures: const [FontFeature.enable('smcp')],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 1,
            width: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gold.withAlpha(160), Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings card container ──────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.nightBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withAlpha(25), width: 1),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// ─── Single settings tile ─────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.sublabel,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      splashColor: AppColors.gold.withAlpha(12),
      highlightColor: AppColors.gold.withAlpha(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.goldDim,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.gold),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                  if (sublabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sublabel!,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.cream.withAlpha(128),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.cream.withAlpha(100),
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 66,
      endIndent: 0,
      color: AppColors.cream.withAlpha(18),
    );
  }
}

// ─── Storage card with visual indicator ───────────────────────────────────────

class _StorageCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_StorageCard> createState() => _StorageCardState();
}

class _StorageCardState extends ConsumerState<_StorageCard> {
  int _count = 0;
  int _bytes = 0;
  bool _loaded = false;

  // Assume 500 MB soft cap for the progress bar display
  static const int _softCapBytes = 500 * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final count = await AudioCache.fileCount();
    final bytes = await AudioCache.totalSizeBytes();
    if (mounted) {
      setState(() {
        _count = count;
        _bytes = bytes;
        _loaded = true;
      });
    }
  }

  String _formatMB(int bytes) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.nightBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withAlpha(25), width: 1),
        ),
        child: Text(
          'Calculando...',
          style: GoogleFonts.nunito(color: AppColors.cream.withAlpha(128)),
        ),
      );
    }

    final progress = (_bytes / _softCapBytes).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nightBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withAlpha(25), width: 1),
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
                  color: AppColors.goldDim,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.download_outlined,
                  size: 18,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_count ${_count == 1 ? 'cuento descargado' : 'cuentos descargados'}',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cream,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatMB(_bytes),
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.cream.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  await AudioCache.clearAll();
                  _load();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Borrar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Gold progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.cream.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8 ? AppColors.terracotta : AppColors.gold,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Logout button ────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.terracotta.withAlpha(30),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.terracotta,
            side: BorderSide(color: AppColors.terracotta.withAlpha(160), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: AppColors.terracotta.withAlpha(12),
          ),
          onPressed: onPressed,
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: Text(
            'Cerrar sesion',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Delivery time picker ─────────────────────────────────────────────────────

class _DeliveryTimePicker extends StatelessWidget {
  final int currentHour;
  final ValueChanged<int> onSelect;

  const _DeliveryTimePicker({required this.currentHour, required this.onSelect});

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h:00 $period';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.cream.withAlpha(38),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Hora de entrega',
            style: GoogleFonts.fraunces(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.cream,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: 12, // hours 12 through 23
            itemBuilder: (_, index) {
              final hour = 12 + index;
              final isSelected = hour == currentHour;
              return ListTile(
                title: Text(
                  _formatHour(hour),
                  style: GoogleFonts.nunito(
                    color: isSelected ? AppColors.gold : AppColors.cream,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.gold, size: 20)
                    : null,
                onTap: () => onSelect(hour),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Loading / error placeholders ────────────────────────────────────────────

class _TileLoading extends StatelessWidget {
  const _TileLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Cargando...',
        style: GoogleFonts.nunito(color: AppColors.cream.withAlpha(128)),
      ),
    );
  }
}

class _TileError extends StatelessWidget {
  const _TileError();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Error al cargar',
        style: GoogleFonts.nunito(color: AppColors.error.withAlpha(200)),
      ),
    );
  }
}
