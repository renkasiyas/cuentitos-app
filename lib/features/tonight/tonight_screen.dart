import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../db/database.dart';
import '../../providers/stories_provider.dart';
import '../../providers/child_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/download_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/reader_theme.dart';
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
      appBar: AppBar(
        title: const Text('Esta noche'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!isOnline)
              Container(
                width: double.infinity,
                color: AppColors.warning,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text(
                  'Sin conexion',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
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
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    bool isActive,
    bool isPremium,
    AsyncValue<Story?> storyAsync,
    AsyncValue<dynamic> parentAsync,
  ) {
    // Not subscribed
    if (!isActive) {
      return _NotSubscribedState(onSubscribe: () => context.push('/tier', extra: <String, dynamic>{}));
    }

    return storyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (story) {
        // No story or still pending
        if (story == null || story.generationStatus == 'pending') {
          final deliveryHour = parentAsync.value?.deliveryHour ?? 18;
          return _PendingState(deliveryHour: deliveryHour);
        }

        // Story is being generated
        if (story.generationStatus == 'generating') {
          return const _GeneratingState();
        }

        // Story generation failed
        if (story.generationStatus == 'failed') {
          return const _FailedState();
        }

        // Story is ready
        return _StoryCard(story: story, isPremium: isPremium, ref: ref);
      },
    );
  }
}

// ─── Not subscribed ───────────────────────────────────────────────────────────

class _NotSubscribedState extends StatelessWidget {
  final VoidCallback onSubscribe;
  const _NotSubscribedState({required this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.nights_stay, size: 72, color: AppColors.gold),
          const SizedBox(height: 24),
          const Text(
            'Suscribete para recibir cuentos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.cream),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onSubscribe,
            child: const Text('Ver planes'),
          ),
        ],
      ),
    );
  }
}

// ─── Pending (story not generated yet) ───────────────────────────────────────

class _PendingState extends StatelessWidget {
  final int deliveryHour;
  const _PendingState({required this.deliveryHour});

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h:00 $period';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.nights_stay, size: 72, color: AppColors.gold),
          const SizedBox(height: 24),
          Text(
            'Tu cuento llega a las ${_formatHour(deliveryHour)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.cream),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Generating ──────────────────────────────────────────────────────────────

class _GeneratingState extends StatelessWidget {
  const _GeneratingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text(
            'Tu cuento se esta preparando...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.cream),
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied_outlined, size: 72, color: AppColors.gold),
          SizedBox(height: 24),
          Text(
            'Hubo un problema. Tu cuento llegara pronto.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.cream),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Story card ───────────────────────────────────────────────────────────────

class _StoryCard extends StatelessWidget {
  final Story story;
  final bool isPremium;
  final WidgetRef ref;

  const _StoryCard({required this.story, required this.isPremium, required this.ref});

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
    final tags = _parseTags(story.themeTags);
    final rawBody = story.bodyText ?? '';
    final preview = stripTtsTags(rawBody.length > 200 ? rawBody.substring(0, 200) : rawBody);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero card
          Container(
            decoration: const BoxDecoration(
              gradient: ReaderTheme.backgroundGradient,
              borderRadius: BorderRadius.all(Radius.circular(20)),
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
                          (tag) => Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 12, color: AppColors.cream),
                            ),
                            backgroundColor: Colors.white12,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        )
                        .toList(),
                  ),
                if (tags.isNotEmpty) const SizedBox(height: 16),

                // Title
                Text(
                  story.title ?? '',
                  style: ReaderTheme.titleStyle,
                ),
                const SizedBox(height: 12),

                // Body preview
                Text(
                  '$preview...',
                  style: ReaderTheme.bodyStyle.copyWith(fontSize: 14),
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

          // Listen button (premium only, requires audioUrl)
          if (isPremium && story.audioUrl != null)
            OutlinedButton.icon(
              onPressed: () => context.push('/reader/${story.id}'),
              icon: const Icon(Icons.headphones),
              label: const Text('Escuchar cuento'),
            ),

          const SizedBox(height: 8),

          // Download button
          _DownloadButton(story: story, ref: ref),
        ],
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
            child: CircularProgressIndicator(strokeWidth: 2),
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
