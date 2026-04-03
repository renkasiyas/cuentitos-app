import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _themeFilter;
  bool _showPlaylists = false;
  late AnimationController _entranceCtrl;
  late Animation<double> _entranceFade;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entranceFade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _entranceCtrl.dispose();
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
      backgroundColor: AppColors.nightBlue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cream.withAlpha(38),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Text(
                  story.title ?? 'Sin título',
                  style: GoogleFonts.fraunces(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(height: 1, color: AppColors.cream.withAlpha(20)),
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
                  style: GoogleFonts.nunito(color: AppColors.cream),
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
              ListTile(
                leading: Icon(
                  story.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: story.isFavorite ? AppColors.terracotta : AppColors.gold,
                ),
                title: Text(
                  story.isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                  style: GoogleFonts.nunito(color: AppColors.cream),
                ),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await db.storyDao.toggleFavorite(story.id, !story.isFavorite);
                  if (mounted) setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add, color: AppColors.gold),
                title: Text(
                  'Agregar a playlist',
                  style: GoogleFonts.nunito(color: AppColors.cream),
                ),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  _showAddToPlaylistSheet(context, story);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showAddToPlaylistSheet(BuildContext ctx, Story story) {
    final db = ref.read(databaseProvider);
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.nightBlue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cream.withAlpha(38),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Text(
                      'Agregar a playlist',
                      style: GoogleFonts.fraunces(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cream,
                      ),
                    ),
                  ),
                  Divider(height: 1, color: AppColors.cream.withAlpha(20)),
                  if (snap.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: AppColors.gold),
                    )
                  else if (playlists.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No tienes playlists todavía.',
                        style: GoogleFonts.nunito(
                          color: AppColors.cream.withAlpha(128),
                        ),
                      ),
                    )
                  else
                    ...playlists.map(
                      (pl) => ListTile(
                        leading: const Icon(Icons.queue_music, color: AppColors.gold),
                        title: Text(
                          pl.name,
                          style: GoogleFonts.nunito(color: AppColors.cream),
                        ),
                        onTap: () async {
                          Navigator.of(sheetCtx).pop();
                          final existing =
                              await db.playlistDao.getPlaylistStories(pl.id);
                          final ids = existing.map((s) => s.id).toList();
                          if (!ids.contains(story.id)) {
                            ids.add(story.id);
                            await db.playlistDao.setPlaylistStories(pl.id, ids);
                          }
                        },
                      ),
                    ),
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
      backgroundColor: AppColors.skyDeep,
      body: Stack(
        children: [
          // Night sky gradient — deeper at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF060810), AppColors.skyDeep],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),

          // Subtle gold glow top-left
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withAlpha(12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Background star field
          ..._buildStarField(context),

          // Full screen content
          FadeTransition(
            opacity: _entranceFade,
            child: SafeArea(
              child: Column(
                children: [
                  // Custom app bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        Text(
                          'Biblioteca',
                          style: GoogleFonts.fraunces(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cream,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Search bar with warm glow
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withAlpha(18),
                            blurRadius: 16,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: GoogleFonts.nunito(color: AppColors.cream),
                        decoration: InputDecoration(
                          hintText: 'Buscar cuentos...',
                          hintStyle: GoogleFonts.nunito(
                            color: AppColors.cream.withAlpha(102),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.gold.withAlpha(180),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: AppColors.cream.withAlpha(128),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Filter chips row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        if (_themeFilter != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _PillChip(
                              label: _themeFilter!,
                              isActive: true,
                              showDelete: true,
                              onDeleted: _clearThemeFilter,
                            ),
                          ),
                        _TogglePillChip(
                          label: 'Playlists',
                          selected: _showPlaylists,
                          onSelected: (val) =>
                              setState(() => _showPlaylists = val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Playlists section
                  if (_showPlaylists) const PlaylistListWidget(),

                  // Story list
                  Expanded(
                    child: storiesAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: AppColors.gold),
                      ),
                      error: (e, _) => Center(
                        child: Text(
                          'Error al cargar: $e',
                          style: GoogleFonts.nunito(
                            color: AppColors.cream.withAlpha(128),
                          ),
                        ),
                      ),
                      data: (stories) {
                        if (stories.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.auto_stories_outlined,
                                  size: 48,
                                  color: AppColors.gold.withAlpha(80),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty || _themeFilter != null
                                      ? 'Sin resultados'
                                      : 'Aún no hay cuentos',
                                  style: GoogleFonts.nunito(
                                    color: AppColors.cream.withAlpha(128),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: stories.length,
                          itemBuilder: (context, i) {
                            final story = stories[i];
                            final tags = _parseTags(story.themeTags);
                            final status = downloadState.statusFor(story.id);

                            return _StoryListCard(
                              story: story,
                              tags: tags,
                              status: status,
                              bodyPreview: _bodyPreview(story.bodyText),
                              dateFormatted: _formatDate(story.storyDate),
                              activeThemeFilter: _themeFilter,
                              onTap: () => context.push('/reader/${story.id}'),
                              onLongPress: () =>
                                  _showContextMenu(context, story),
                              onThemeTap: _setThemeFilter,
                              onFavoriteTap: () async {
                                final db = ref.read(databaseProvider);
                                await db.storyDao
                                    .toggleFavorite(story.id, !story.isFavorite);
                                ref.invalidate(storiesProvider(filter));
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStarField(BuildContext context) {
    final rand = math.Random(42);
    final stars = <Widget>[];
    final size = MediaQuery.of(context).size;
    for (int i = 0; i < 6; i++) {
      final top = rand.nextDouble() * size.height * 0.35;
      final left = rand.nextDouble() * size.width;
      final starSize = i < 2 ? 3.0 : 1.8;
      stars.add(
        Positioned(
          top: top,
          left: left,
          child: Container(
            width: starSize,
            height: starSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < 2
                  ? AppColors.goldLight.withAlpha(160)
                  : AppColors.cream.withAlpha(100),
              boxShadow: i < 2
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withAlpha(60),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      );
    }
    return stars;
  }
}

// ─── Story list card ─────────────────────────────────────────────────────────

class _StoryListCard extends StatelessWidget {
  final Story story;
  final List<String> tags;
  final DownloadStatus status;
  final String bodyPreview;
  final String dateFormatted;
  final String? activeThemeFilter;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onFavoriteTap;
  final ValueChanged<String> onThemeTap;

  const _StoryListCard({
    required this.story,
    required this.tags,
    required this.status,
    required this.bodyPreview,
    required this.dateFormatted,
    required this.activeThemeFilter,
    required this.onTap,
    required this.onLongPress,
    required this.onFavoriteTap,
    required this.onThemeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.nightBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.gold.withAlpha(31),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            onLongPress: onLongPress,
            splashColor: AppColors.gold.withAlpha(15),
            highlightColor: AppColors.gold.withAlpha(8),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with status icons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          story.title ?? 'Sin título',
                          style: GoogleFonts.fraunces(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.cream,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _DownloadIcon(status: status),
                      const SizedBox(width: 6),
                      _FavoriteIcon(
                        isFavorite: story.isFavorite,
                        onTap: onFavoriteTap,
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Date
                  Text(
                    dateFormatted,
                    style: GoogleFonts.nunito(
                      color: AppColors.cream.withAlpha(100),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Body preview
                  if (bodyPreview.isNotEmpty)
                    Text(
                      bodyPreview,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.cream.withAlpha(179),
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  // Theme tags
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: tags
                          .map(
                            (tag) => GestureDetector(
                              onTap: () => onThemeTap(tag),
                              child: _PillChip(
                                label: tag,
                                isActive: activeThemeFilter == tag,
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
        ),
      ),
    );
  }
}

// ─── Pill chip ───────────────────────────────────────────────────────────────

class _PillChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool showDelete;
  final VoidCallback? onDeleted;

  const _PillChip({
    required this.label,
    required this.isActive,
    this.showDelete = false,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: showDelete ? 4 : 10,
        top: 4,
        bottom: 4,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.goldDim : AppColors.cream.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive
              ? AppColors.gold.withAlpha(80)
              : AppColors.cream.withAlpha(25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.goldLight : AppColors.cream.withAlpha(179),
            ),
          ),
          if (showDelete && onDeleted != null) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onDeleted,
              child: Icon(
                Icons.close,
                size: 13,
                color: isActive ? AppColors.goldLight : AppColors.cream.withAlpha(128),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TogglePillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _TogglePillChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.goldDim : AppColors.cream.withAlpha(18),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.gold.withAlpha(80)
                : AppColors.cream.withAlpha(25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check, size: 12, color: AppColors.gold),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.goldLight : AppColors.cream.withAlpha(179),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Download icon ────────────────────────────────────────────────────────────

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
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
          ),
        );
      case DownloadStatus.done:
        return const Icon(Icons.download_done, size: 18, color: AppColors.success);
      case DownloadStatus.error:
        return const Icon(Icons.error_outline, size: 18, color: AppColors.error);
      case DownloadStatus.idle:
        return const SizedBox.shrink();
    }
  }
}

// ─── Favorite icon ────────────────────────────────────────────────────────────

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
        color: isFavorite ? AppColors.terracotta : AppColors.cream.withAlpha(128),
      ),
    );
  }
}
