import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.goldDim,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.auto_stories,
                  size: 80,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Cuentitos',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.cream,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Cuentos personalizados para tu hijo/a',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.cream.withAlpha(166),
                    ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Comenzar'),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
