import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/sync/sync_provider.dart';
import '../../theme/app_theme.dart';

class WaitingScreen extends ConsumerStatefulWidget {
  const WaitingScreen({super.key});

  @override
  ConsumerState<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends ConsumerState<WaitingScreen> {
  Timer? _timer;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Poll immediately then every 5 seconds
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _poll());
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
          _timer?.cancel();
          setState(() => _syncing = true);
          await ref.read(syncProvider).fullSync();
          if (mounted) context.go('/tonight');
        }
      }
    } catch (_) {
      // Silently retry on next tick
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.gold,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 40),
                Text(
                  'Preparando tu primer cuento...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.cream,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Esto puede tomar un momento. Estamos creando una historia única para tu hijo/a.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.cream.withAlpha(153),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
