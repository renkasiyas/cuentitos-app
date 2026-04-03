import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/sync/sync_provider.dart';
import '../../core/storage/audio_cache.dart';
import '../../core/api/endpoints.dart';
import '../../providers/download_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../db/database.dart';
import 'tts_stripper.dart';
import 'audio_player_bar.dart';
import '../../theme/reader_theme.dart';
import '../../theme/app_theme.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String storyId;
  const ReaderScreen({super.key, required this.storyId});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  String? _localAudioPath;
  bool _checkingAudio = true;
  Story? _story;
  bool _loadingStory = true;

  @override
  void initState() {
    super.initState();
    _loadStory();
    _checkLocalAudio();
  }

  Future<void> _loadStory() async {
    final db = ref.read(databaseProvider);
    final story = await db.storyDao.getStoryById(widget.storyId);
    if (mounted) {
      setState(() {
        _story = story;
        _loadingStory = false;
      });
    }
  }

  Future<void> _checkLocalAudio() async {
    final exists = await AudioCache.exists(widget.storyId);
    if (exists) {
      final path = await AudioCache.filePath(widget.storyId);
      if (mounted) {
        setState(() {
          _localAudioPath = path;
          _checkingAudio = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _checkingAudio = false);
      }
    }
  }

  Future<void> _triggerDownload() async {
    await ref.read(downloadProvider.notifier).download(widget.storyId);
    await _checkLocalAudio();
  }

  Future<void> _toggleFavorite() async {
    if (_story == null) return;
    final db = ref.read(databaseProvider);
    final newVal = !_story!.isFavorite;
    await db.storyDao.toggleFavorite(widget.storyId, newVal);
    final updated = await db.storyDao.getStoryById(widget.storyId);
    if (mounted) setState(() => _story = updated);
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);
    final downloadState = ref.watch(downloadProvider);
    final isDownloading =
        downloadState.statusFor(widget.storyId) == DownloadStatus.downloading;

    if (_loadingStory) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: ReaderTheme.backgroundGradient),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final story = _story;
    if (story == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: ReaderTheme.backgroundGradient),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, null, isPremium),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Historia no encontrada',
                      style: TextStyle(color: AppColors.cream),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final hasAudioUrl = story.audioUrl != null && story.audioUrl!.isNotEmpty;
    final String? audioSource = _localAudioPath ??
        (hasAudioUrl ? '${Endpoints.baseUrl}${story.audioUrl}' : null);
    final showPlayer = isPremium && hasAudioUrl && audioSource != null && !_checkingAudio;
    final showDownloadButton =
        isPremium && hasAudioUrl && _localAudioPath == null && !_checkingAudio;

    return Scaffold(
      body: Container(
      decoration: const BoxDecoration(gradient: ReaderTheme.backgroundGradient),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _buildTopBar(context, story, isPremium),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (story.title != null && story.title!.isNotEmpty) ...[
                    Text(
                      story.title!,
                      style: ReaderTheme.titleStyle,
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (story.bodyText != null && story.bodyText!.isNotEmpty)
                    Text(
                      stripTtsTags(story.bodyText!),
                      style: ReaderTheme.bodyStyle,
                    ),
                  if (showDownloadButton) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: isDownloading
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.gold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Descargando\u2026',
                                  style: TextStyle(color: AppColors.cream),
                                ),
                              ],
                            )
                          : TextButton(
                              onPressed: _triggerDownload,
                              child: const Text(
                                'Descargar audio',
                                style: TextStyle(color: AppColors.gold),
                              ),
                            ),
                    ),
                  ],
                  // Bottom padding so content clears player bar
                  if (showPlayer) const SizedBox(height: 160),
                ],
              ),
            ),
          ),
          // audioSource is non-null when showPlayer is true (guarded by showPlayer condition)
          if (showPlayer) AudioPlayerBar(audioSource: audioSource!), // ignore: unnecessary_non_null_assertion
        ],
      ),
    ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    Story? story,
    bool isPremium,
  ) {
    final hasAudioUrl = story?.audioUrl != null && story!.audioUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.cream),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          // Favorite heart
          if (story != null)
            IconButton(
              icon: Icon(
                story.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: story.isFavorite ? AppColors.terracotta : AppColors.cream,
              ),
              onPressed: _toggleFavorite,
            ),
          // Download button (premium + has audio)
          if (story != null && isPremium && hasAudioUrl)
            Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(downloadProvider);
                final status = state.statusFor(widget.storyId);
                if (status == DownloadStatus.downloading) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cream),
                    ),
                  );
                }
                if (_localAudioPath != null || status == DownloadStatus.done) {
                  return Icon(Icons.download_done, color: AppColors.cream.withAlpha(179));
                }
                return IconButton(
                  icon: const Icon(Icons.download_outlined, color: AppColors.cream),
                  onPressed: _triggerDownload,
                );
              },
            ),
          // Share button
          if (story != null)
            IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.cream),
              onPressed: () {
                final title = story.title ?? 'Cuentito';
                Share.share('$title \u2014 escuchado en Cuentitos');
              },
            ),
        ],
      ),
    );
  }
}
