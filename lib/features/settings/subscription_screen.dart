import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../providers/child_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../theme/app_theme.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(subscriptionTierProvider);
    final status = ref.watch(subscriptionStatusProvider);
    final isActive = ref.watch(isActiveSubscriberProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final isCanceled = status == 'canceled';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suscripción'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Current plan card ──────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.goldDim,
              border: Border.all(color: AppColors.gold, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tier == 'premium' ? 'Plan Premium' : 'Plan Básico',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cream,
                      ),
                    ),
                    _StatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  tier == 'premium' ? '\$149 MXN / mes' : '\$79 MXN / mes',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tier == 'premium'
                      ? 'Audio de alta calidad + sin anuncios'
                      : 'Un cuento al dia',
                  style: TextStyle(fontSize: 13, color: AppColors.cream.withAlpha(128)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Change plan (only if active subscription) ─────────────────────
          if (isActive) ...[
            ElevatedButton(
              onPressed: () => _changeTier(context, ref, tier),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPremium ? AppColors.nightBlue : AppColors.gold,
                foregroundColor: isPremium ? AppColors.cream : AppColors.skyDeep,
              ),
              child: Text(
                isPremium ? 'Cambiar a Plan Básico' : 'Cambiar a Premium',
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Reactivate (if canceled) ───────────────────────────────────────
          if (isCanceled) ...[
            ElevatedButton(
              onPressed: () => _reactivate(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.cream,
              ),
              child: const Text('Reactivar suscripción'),
            ),
            const SizedBox(height: 12),
          ],

          // ── Manage payments ───────────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () => _openBillingPortal(context, ref),
            icon: const Icon(Icons.credit_card),
            label: const Text('Administrar pagos'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeTier(BuildContext context, WidgetRef ref, String currentTier) async {
    final newTier = currentTier == 'premium' ? 'basico' : 'premium';
    final newPrice = newTier == 'premium' ? '\$149' : '\$79';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cambiar a ${newTier == "premium" ? "Premium" : "Básico"}'),
        content: Text(
          newTier == 'premium'
              ? 'Se cambiará tu plan a Premium por $newPrice MXN/mes.'
              : 'Se cambiará tu plan a Básico. Perderás acceso a audios y funciones premium.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final dio = ref.read(apiClientProvider);
      await dio.post(Endpoints.tier, data: {'tier': newTier});
      ref.invalidate(parentProfileProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cambiar el plan')),
        );
      }
    }
  }

  Future<void> _reactivate(BuildContext context, WidgetRef ref) async {
    // Reactivation is handled by Stripe billing portal — open it directly
    await _openBillingPortal(context, ref);
  }

  Future<void> _openBillingPortal(BuildContext context, WidgetRef ref) async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.post(Endpoints.billing);
      final url = response.data['url'] as String;
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => _BillingWebView(url: url)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al abrir el portal de pagos')),
        );
      }
    }
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'active' => ('Activo', AppColors.success),
      'canceled' => ('Cancelado', AppColors.error),
      'past_due' => ('Vencido', AppColors.warning),
      _ => ('Pendiente', AppColors.cream),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ─── Billing WebView ──────────────────────────────────────────────────────────

class _BillingWebView extends StatefulWidget {
  final String url;
  const _BillingWebView({required this.url});

  @override
  State<_BillingWebView> createState() => _BillingWebViewState();
}

class _BillingWebViewState extends State<_BillingWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar pagos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
