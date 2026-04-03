import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/sync/sync_provider.dart';
import '../../db/database.dart';
import '../../theme/app_theme.dart';

class PlaylistListWidget extends ConsumerWidget {
  const PlaylistListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _PlaylistListBody();
  }
}

class _PlaylistListBody extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PlaylistListBody> createState() => _PlaylistListBodyState();
}

class _PlaylistListBodyState extends ConsumerState<_PlaylistListBody> {
  late Future<List<Playlist>> _playlistsFuture;
  late Future<int> _favoritesFuture;
  late Future<int> _downloadedFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final db = ref.read(databaseProvider);
    _playlistsFuture = db.playlistDao.getAllPlaylists();
    _favoritesFuture = db.storyDao.getFavorites().then((l) => l.length);
    _downloadedFuture = db.storyDao.getDownloaded().then((l) => l.length);
  }

  Future<void> _showCreateDialog() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nombre de la playlist',
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final name = controller.text.trim();
    if (name.isEmpty) return;

    final db = ref.read(databaseProvider);
    final dio = ref.read(apiClientProvider);
    final newId = const Uuid().v4();
    final now = DateTime.now().toUtc();

    // Optimistically insert into local DB
    await db.playlistDao.upsertPlaylist(PlaylistsCompanion.insert(
      id: newId,
      name: name,
      createdAt: now,
    ));

    // Try to POST to API; queue offline action on failure
    try {
      final response = await dio.post(Endpoints.playlists, data: jsonEncode({'name': name, 'id': newId}));
      final serverId = response.data['id'] as String? ?? newId;
      if (serverId != newId) {
        // Server returned a different id — update local record
        await db.playlistDao.upsertPlaylist(PlaylistsCompanion.insert(
          id: serverId,
          name: name,
          createdAt: now,
        ));
        await db.playlistDao.deletePlaylist(newId);
      }
    } catch (_) {
      // Offline — keep local record as-is; sync will reconcile later
    }

    if (mounted) {
      setState(() => _reload());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Playlists',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.gold),
                onPressed: _showCreateDialog,
                tooltip: 'Crear playlist',
              ),
            ],
          ),
        ),

        // Auto-playlists
        FutureBuilder<int>(
          future: _favoritesFuture,
          builder: (context, snap) {
            final count = snap.data ?? 0;
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.goldDim,
                child: Icon(Icons.favorite, color: AppColors.gold, size: 20),
              ),
              title: const Text('Favoritos'),
              trailing: Text('$count', style: TextStyle(color: AppColors.cream.withAlpha(128))),
              onTap: () => context.push('/library/playlist/favorites'),
            );
          },
        ),

        FutureBuilder<int>(
          future: _downloadedFuture,
          builder: (context, snap) {
            final count = snap.data ?? 0;
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.goldDim,
                child: Icon(Icons.download_done, color: AppColors.gold, size: 20),
              ),
              title: const Text('Descargados'),
              trailing: Text('$count', style: TextStyle(color: AppColors.cream.withAlpha(128))),
              onTap: () => context.push('/library/playlist/downloaded'),
            );
          },
        ),

        // User playlists
        FutureBuilder<List<Playlist>>(
          future: _playlistsFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final playlists = snap.data ?? [];
            if (playlists.isEmpty) return const SizedBox.shrink();
            return Column(
              children: playlists
                  .map(
                    (pl) => ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.goldDim,
                        child: Icon(Icons.queue_music, color: AppColors.gold, size: 20),
                      ),
                      title: Text(pl.name),
                      onTap: () => context.push('/library/playlist/${pl.id}'),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
