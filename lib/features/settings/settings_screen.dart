import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentAsync = ref.watch(parentProfileProvider);
    final childAsync = ref.watch(childProfileProvider);
    final tier = ref.watch(subscriptionTierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // ── Profile ───────────────────────────────────────────────────────
          _SectionHeader('Perfil'),
          childAsync.when(
            loading: () => const ListTile(title: Text('Cargando...')),
            error: (_, __) => const ListTile(title: Text('Error al cargar perfil')),
            data: (child) => ListTile(
              title: Text(child?.name ?? '—'),
              subtitle: Text(
                [
                  if (child?.favoriteAnimal != null) child!.favoriteAnimal,
                  if (child?.favoriteColor != null) child!.favoriteColor,
                ].join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/profile'),
            ),
          ),
          const Divider(height: 1),

          // ── Subscription ──────────────────────────────────────────────────
          _SectionHeader('Suscripcion'),
          ListTile(
            title: Text(tier == 'premium' ? 'Plan Premium' : 'Plan Basico'),
            subtitle: Text(tier == 'premium' ? '\$99 MXN / mes' : 'Gratis'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/subscription'),
          ),
          const Divider(height: 1),

          // ── Delivery ──────────────────────────────────────────────────────
          _SectionHeader('Hora de entrega'),
          parentAsync.when(
            loading: () => const ListTile(title: Text('Cargando...')),
            error: (_, __) => const ListTile(title: Text('Error al cargar')),
            data: (parent) {
              final hour = parent?.deliveryHour ?? 18;
              return ListTile(
                title: const Text('Hora de tu cuento'),
                subtitle: Text(_formatHour(hour)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _showDeliveryTimePicker(context, ref, hour),
              );
            },
          ),
          const Divider(height: 1),

          // ── Storage ───────────────────────────────────────────────────────
          _SectionHeader('Almacenamiento'),
          _StorageTile(),
          const Divider(height: 1),

          // ── About ─────────────────────────────────────────────────────────
          _SectionHeader('Acerca de'),
          ListTile(
            title: const Text('Version'),
            trailing: Text('1.0.0', style: TextStyle(color: AppColors.cream.withAlpha(128))),
          ),
          ListTile(
            title: const Text('Politica de privacidad'),
            trailing: Icon(Icons.open_in_new, size: 18, color: AppColors.cream.withAlpha(128)),
            onTap: () {
              // Could open webview; for now placeholder action
            },
          ),
          ListTile(
            title: const Text('Soporte'),
            subtitle: const Text('hola@cuentitos.mx'),
            trailing: Icon(Icons.mail_outline, size: 18, color: AppColors.cream.withAlpha(128)),
            onTap: () {},
          ),
          const Divider(height: 1),

          // ── Logout ────────────────────────────────────────────────────────
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/welcome');
              },
              child: const Text('Cerrar sesion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h:00 $period';
  }

  void _showDeliveryTimePicker(BuildContext context, WidgetRef ref, int currentHour) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              await ref.read(pendingActionsProvider).enqueue('delivery_time', {'hour': hour});
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
}

// ─── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.cream.withAlpha(128),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Storage Tile ─────────────────────────────────────────────────────────────

class _StorageTile extends ConsumerStatefulWidget {
  @override
  ConsumerState<_StorageTile> createState() => _StorageTileState();
}

class _StorageTileState extends ConsumerState<_StorageTile> {
  int _count = 0;
  int _bytes = 0;
  bool _loaded = false;

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
      return const ListTile(title: Text('Calculando...'));
    }
    return ListTile(
      title: Text('$_count cuentos descargados (${_formatMB(_bytes)})'),
      trailing: TextButton(
        onPressed: () async {
          await AudioCache.clearAll();
          _load();
        },
        child: const Text('Borrar', style: TextStyle(color: AppColors.error)),
      ),
    );
  }
}

// ─── Delivery Time Picker ─────────────────────────────────────────────────────

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
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Hora de entrega',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.cream),
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
                  style: TextStyle(
                    color: isSelected ? AppColors.gold : AppColors.cream,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.gold)
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
