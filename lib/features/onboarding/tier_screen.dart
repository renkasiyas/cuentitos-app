import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class TierScreen extends StatefulWidget {
  final Map<String, dynamic> quizData;

  const TierScreen({super.key, required this.quizData});

  @override
  State<TierScreen> createState() => _TierScreenState();
}

class _TierScreenState extends State<TierScreen> {
  String _selectedTier = 'basico';

  void _continue() {
    context.go('/checkout', extra: {
      ...widget.quizData,
      'tier': _selectedTier,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Elige tu plan'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                'Elige el plan perfecto para tu familia',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.cream.withAlpha(166),
                    ),
              ),
              const SizedBox(height: 24),
              _TierCard(
                title: 'Básico',
                price: '\$79/mes',
                features: const [
                  '1 cuento por semana',
                  'Personalización básica',
                  'Audio narrado por IA',
                  'Biblioteca de cuentos',
                ],
                selected: _selectedTier == 'basico',
                onTap: () => setState(() => _selectedTier = 'basico'),
              ),
              const SizedBox(height: 16),
              _TierCard(
                title: 'Premium',
                price: '\$149/mes',
                badge: 'Más popular',
                features: const [
                  '3 cuentos por semana',
                  'Personalización avanzada',
                  'Voces premium narradas',
                  'Biblioteca completa',
                  'Listas de reproducción',
                  'Soporte prioritario',
                ],
                selected: _selectedTier == 'premium',
                onTap: () => setState(() => _selectedTier = 'premium'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _continue,
                child: const Text('Continuar al pago'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final String title;
  final String price;
  final String? badge;
  final List<String> features;
  final bool selected;
  final VoidCallback onTap;

  const _TierCard({
    required this.title,
    required this.price,
    this.badge,
    required this.features,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppColors.goldDim : AppColors.nightBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.cream.withAlpha(38),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.cream,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: AppColors.skyDeep,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  price,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: AppColors.gold),
                      const SizedBox(width: 8),
                      Text(
                        f,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.cream.withAlpha(204),
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
