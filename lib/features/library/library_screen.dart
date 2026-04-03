import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../db/database.dart';
import '../../providers/stories_provider.dart';
import '../../providers/download_provider.dart';
import '../../core/sync/sync_provider.dart';
import '../../theme/app_theme.dart';
import '../reader/tts_stripper.dart';
import 'playlist_list.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _themeFilter;
  bool _showPlaylists = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _clearThemeFilter() {
    setState(() => _themeFilter = null);
  }

  void _setThemeFilter(String theme) {
    setState(() => _themeFilter = _themeFilter == theme ? null : theme);
  }

  List<String> _parseTags(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) return decoded.cast<String>();
    } catch (_) {}
    return [];
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _bodyPreview(String? body) {
    if (body == null || body.isEmpty) return '';
    final stripped = stripTtsTags(body);
    if (stripped.length <= 100) return stripped;
    return '${stripped.substring(0, 100)}...';
  }

  void _showContextMenu(BuildContext context, Story story) {
    final db = ref.read(databaseProvider);
    final downloader = ref.read(downloadProvider.notifier);
    final downloadState = ref.read(downloadProvider);
    final downloadStatus = downloadState.statusFor(story.id);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  story.title ?? 'Sin título',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cream,
                  ),
                ),
              ),
              const Divider(height: 1),
              // Download / Delete
              ListTile(
                leading: Icon(
                  downloadStatus == DownloadStatus.done
                      ? Icons.delete_outline
                      : Icons.download_outlined,
                  color: AppColors.gold,
                ),
                title: Text(
                  downloadStatus == DownloadStatus.done
                      ? 'Eliminar descarga'
                      : downloadStatus == DownloadStatus.downloading
                          ? 'Descargando...'
                          : 'Descargar',
                ),
                onTap: downloadStatus == DownloadStatus.downloading
                    ? null
                    : () {
                        Navigator.of(ctx).pop();
                        if (downloadStatus == DownloadStatus.done) {
                          downloader.deleteDownload(story.id);
                        } else {
                          downloader.download(story.id);
                        }
                      },
              ),
              // Favorite toggle
              ListTile(
                leading: Icon(
                  story.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.gold,
                ),
                title: Text(story.isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await db.storyDao.toggleFavorite(story.id, !story.isFavorite);
                  if (mounted) setState(() {});
                },
              ),
              // Add to playlist
              ListTile(
                leading: const Icon(Icons.playlist_add, color: AppColors.gold),
                title: const Text('Agregar a playlist'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  _showAddToPlaylistSheet(context, story);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddToPlaylistSheet(BuildContext ctx, Story story) {
    final db = ref.read(databaseProvider);
    // Load playlists inside the sheet using a FutureBuilder — no async gap
    // before showModalBottomSheet, so context is safe.
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: FutureBuilder<List<Playlist>>(
            future: db.playlistDao.getAllPlaylists(),
            builder: (_, snap) {
              final playlists = snap.data ?? [];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      'Agregar a playlist',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cream,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  if (snap.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    )
                  else if (playlists.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('No tienes playlists todavía.',
                          style: TextStyle(color: AppColors.cream.withAlpha(128))),
                    )
                  else
                    ...playlists.map((pl) => ListTile(
                          leading: const Icon(Icons.queue_music,
                              color: AppColors.gold),
                          title: Text(pl.name),
                          onTap: () async {
                            Navigator.of(sheetCtx).pop();
                            final existing =
                                await db.playlistDao.getPlaylistStories(pl.id);
                            final ids = existing.map((s) => s.id).toList();
                            if (!ids.contains(story.id)) {
                              ids.add(story.id);
                              await db.playlistDao
                                  .setPlaylistStories(pl.id, ids);
                            }
                          },
                        )),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = StoryFilter(
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      themeFilter: _themeFilter,
    );
    final storiesAsync = ref.watch(storiesProvider(filter));
    final downloadState = ref.watch(downloadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar cuentos...',
                prefixIcon: Icon(Icons.search, color: AppColors.cream.withAlpha(128)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.cream.withAlpha(128)),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Filter chips row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Active theme filter chip
                if (_themeFilter != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(_themeFilter!),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: _clearThemeFilter,
                      backgroundColor: AppColors.goldDim,
                      labelStyle: const TextStyle(color: AppColors.gold),
                      side: BorderSide.none,
                    ),
                  ),

                // Playlists toggle
                FilterChip(
                  label: const Text('Playlists'),
                  selected: _showPlaylists,
                  onSelected: (val) => setState(() => _showPlaylists = val),
                  selectedColor: AppColors.goldDim,
                  checkmarkColor: AppColors.gold,
                  labelStyle: TextStyle(
                    color: _showPlaylists ? AppColors.gold : AppColors.cream.withAlpha(179),
                    fontWeight: _showPlaylists
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  side: BorderSide.none,
                ),
              ],
            ),
          ),

          // Playlists section
          if (_showPlaylists) const PlaylistListWidget(),

          // Story list
          Expanded(
            child: storiesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Error al cargar: $e',
                  style: TextStyle(color: AppColors.cream.withAlpha(128)),
                ),
              ),
              data: (stories) {
                if (stories.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isNotEmpty || _themeFilter != null
                          ? 'Sin resultados'
                          : 'Aún no hay cuentos',
                      style: TextStyle(color: AppColors.cream.withAlpha(128), fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: stories.length,
                  itemBuilder: (context, i) {
                    final story = stories[i];
                    final tags = _parseTags(story.themeTags);
                    final status = downloadState.statusFor(story.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      color: AppColors.nightBlue,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.push('/reader/${story.id}'),
                        onLongPress: () =>
                            _showContextMenu(context, story),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title row with download icon and favorite
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      story.title ?? 'Sin título',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppColors.cream,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Download status icon
                                  _DownloadIcon(status: status),
                                  const SizedBox(width: 4),
                                  // Favorite heart
                                  _FavoriteIcon(
                                    isFavorite: story.isFavorite,
                                    onTap: () async {
                                      final db = ref.read(databaseProvider);
                                      await db.storyDao.toggleFavorite(
                                          story.id, !story.isFavorite);
                                      // Invalidate to refresh list
                                      ref.invalidate(storiesProvider(filter));
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              // Date
                              Text(
                                _formatDate(story.storyDate),
                                style: TextStyle(
                                    color: AppColors.cream.withAlpha(128), fontSize: 12),
                              ),

                              const SizedBox(height: 6),

                              // Body preview
                              if (story.bodyText != null &&
                                  story.bodyText!.isNotEmpty)
                                Text(
                                  _bodyPreview(story.bodyText),
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.cream.withAlpha(179)),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),

                              // Theme tags
                              if (tags.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: tags
                                      .map(
                                        (tag) => GestureDetector(
                                          onTap: () => _setThemeFilter(tag),
                                          child: Chip(
                                            label: Text(
                                              tag,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: _themeFilter == tag
                                                    ? AppColors.gold
                                                    : AppColors.cream.withAlpha(179),
                                              ),
                                            ),
                                            backgroundColor:
                                                _themeFilter == tag
                                                    ? AppColors.goldDim
                                                    : AppColors.cream.withAlpha(15),
                                            side: BorderSide.none,
                                            padding: EdgeInsets.zero,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadIcon extends StatelessWidget {
  final DownloadStatus status;
  const _DownloadIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case DownloadStatus.downloading:
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.gold),
          ),
        );
      case DownloadStatus.done:
        return const Icon(Icons.download_done,
            size: 18, color: AppColors.success);
      case DownloadStatus.error:
        return const Icon(Icons.error_outline,
            size: 18, color: AppColors.error);
      case DownloadStatus.idle:
        return const SizedBox.shrink();
    }
  }
}

class _FavoriteIcon extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  const _FavoriteIcon({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        size: 18,
        color: isFavorite ? Colors.red : AppColors.cream.withAlpha(128),
      ),
    );
  }
}
