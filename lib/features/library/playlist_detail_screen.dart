import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/sync/sync_provider.dart';
import '../../db/database.dart';
import '../../theme/app_theme.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final String playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PlaylistDetailBody(playlistId: playlistId);
  }
}

class _PlaylistDetailBody extends ConsumerStatefulWidget {
  final String playlistId;
  const _PlaylistDetailBody({required this.playlistId});

  @override
  ConsumerState<_PlaylistDetailBody> createState() => _PlaylistDetailBodyState();
}

class _PlaylistDetailBodyState extends ConsumerState<_PlaylistDetailBody> {
  late Future<List<Story>> _storiesFuture;
  late Future<String> _titleFuture;
  List<Story> _stories = [];

  bool get _isAuto =>
      widget.playlistId == 'favorites' || widget.playlistId == 'downloaded';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final db = ref.read(databaseProvider);
    switch (widget.playlistId) {
      case 'favorites':
        _storiesFuture = db.storyDao.getFavorites();
        _titleFuture = Future.value('Favoritos');
      case 'downloaded':
        _storiesFuture = db.storyDao.getDownloaded();
        _titleFuture = Future.value('Descargados');
      default:
        _storiesFuture = db.playlistDao.getPlaylistStories(widget.playlistId);
        _titleFuture = db.playlistDao
            .getAllPlaylists()
            .then((list) => list.firstWhere((p) => p.id == widget.playlistId,
                orElse: () => throw StateError('not found')).name);
    }
    _storiesFuture.then((s) {
      if (mounted) setState(() => _stories = s);
    });
  }

  Future<void> _saveOrder() async {
    if (_isAuto) return;
    final db = ref.read(databaseProvider);
    await db.playlistDao.setPlaylistStories(
      widget.playlistId,
      _stories.map((s) => s.id).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _titleFuture,
      builder: (context, titleSnap) {
        final title = titleSnap.data ?? '';
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: BackButton(onPressed: () => context.pop()),
          ),
          body: FutureBuilder<List<Story>>(
            future: _storiesFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}'));
              }
              if (_stories.isEmpty) {
                return Center(
                  child: Text(
                    'No hay cuentos aquí todavía.',
                    style: TextStyle(color: AppColors.cream.withAlpha(128), fontSize: 16),
                  ),
                );
              }
              return Column(
                children: [
                  // "Reproducir todo" button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Reproducir todo'),
                        onPressed: () => context.push('/reader/${_stories.first.id}'),
                      ),
                    ),
                  ),

                  // Story list — reorderable for user playlists, plain for auto
                  Expanded(
                    child: _isAuto
                        ? ListView.builder(
                            itemCount: _stories.length,
                            itemBuilder: (context, i) =>
                                _StoryTile(story: _stories[i]),
                          )
                        : ReorderableListView.builder(
                            itemCount: _stories.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) newIndex -= 1;
                                final item = _stories.removeAt(oldIndex);
                                _stories.insert(newIndex, item);
                              });
                              _saveOrder();
                            },
                            itemBuilder: (context, i) => _StoryTile(
                              key: ValueKey(_stories[i].id),
                              story: _stories[i],
                              trailing: Icon(Icons.drag_handle, color: AppColors.cream.withAlpha(128)),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _StoryTile extends StatelessWidget {
  final Story story;
  final Widget? trailing;
  const _StoryTile({super.key, required this.story, this.trailing});

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        story.title ?? 'Sin título',
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.cream),
      ),
      subtitle: Text(
        _formatDate(story.storyDate),
        style: TextStyle(color: AppColors.cream.withAlpha(128), fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline, color: AppColors.gold),
            onPressed: () => context.push('/reader/${story.id}'),
            tooltip: 'Reproducir',
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
