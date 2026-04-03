import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../theme/reader_theme.dart';
import '../../theme/app_theme.dart';

class AudioPlayerBar extends StatefulWidget {
  final String audioSource; // URL or file path
  const AudioPlayerBar({super.key, required this.audioSource});

  @override
  State<AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends State<AudioPlayerBar> {
  late final AudioPlayer _player;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      if (widget.audioSource.startsWith('http')) {
        await _player.setUrl(widget.audioSource);
      } else {
        await _player.setFilePath(widget.audioSource);
      }
    } catch (_) {
      // Source unavailable — player stays idle
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration? d) {
    if (d == null) return '0:00';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleSpeed() async {
    final newSpeed = _speed == 1.0 ? 0.75 : 1.0;
    await _player.setSpeed(newSpeed);
    setState(() => _speed = newSpeed);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: ReaderTheme.playerBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: StreamBuilder<Duration?>(
          stream: _player.durationStream,
          builder: (context, durationSnapshot) {
            final total = durationSnapshot.data;
            return StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, positionSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;
                final totalSeconds = (total?.inSeconds ?? 0).toDouble();
                final positionSeconds = position.inSeconds.toDouble().clamp(0.0, totalSeconds > 0 ? totalSeconds : 1.0);

                return StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  builder: (context, stateSnapshot) {
                    final playerState = stateSnapshot.data;
                    final isPlaying = playerState?.playing ?? false;
                    final isLoading = playerState?.processingState == ProcessingState.loading ||
                        playerState?.processingState == ProcessingState.buffering;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Scrubber
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppColors.gold,
                            inactiveTrackColor: AppColors.cream.withAlpha(61),
                            thumbColor: AppColors.gold,
                            overlayColor: AppColors.gold.withValues(alpha: 0.2),
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            value: positionSeconds,
                            min: 0.0,
                            max: totalSeconds > 0 ? totalSeconds : 1.0,
                            onChanged: totalSeconds > 0
                                ? (value) => _player.seek(Duration(seconds: value.toInt()))
                                : null,
                          ),
                        ),
                        // Time labels
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(position),
                                style: TextStyle(color: AppColors.cream.withAlpha(179), fontSize: 12),
                              ),
                              Text(
                                _formatDuration(total),
                                style: TextStyle(color: AppColors.cream.withAlpha(179), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Controls row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Speed toggle
                            TextButton(
                              onPressed: _toggleSpeed,
                              child: Text(
                                _speed == 1.0 ? '1x' : '0.75x',
                                style: TextStyle(
                                  color: AppColors.cream.withAlpha(179),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Play/pause
                            SizedBox(
                              width: 56,
                              height: 56,
                              child: isLoading
                                  ? const Center(
                                      child: SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          color: AppColors.cream,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      iconSize: 56,
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                        color: AppColors.cream,
                                        size: 56,
                                      ),
                                      onPressed: () {
                                        if (isPlaying) {
                                          _player.pause();
                                        } else {
                                          _player.play();
                                        }
                                      },
                                    ),
                            ),
                            const SizedBox(width: 24),
                            // Spacer to balance speed button
                            const SizedBox(width: 48),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
