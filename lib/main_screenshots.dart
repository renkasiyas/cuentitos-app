/// Temporary entrypoint for capturing App Store screenshots with mock data.
/// Run with: flutter run -t lib/main_screenshots.dart
/// Delete after capturing screenshots.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'theme/reader_theme.dart';
import 'features/reader/tts_stripper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: _ScreenshotApp()));
}

class _ScreenshotApp extends StatelessWidget {
  const _ScreenshotApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuentitos Screenshots',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const _ScreenshotGallery(),
    );
  }
}

// Navigate between mock screens for screenshots
class _ScreenshotGallery extends StatefulWidget {
  const _ScreenshotGallery();

  @override
  State<_ScreenshotGallery> createState() => _ScreenshotGalleryState();
}

class _ScreenshotGalleryState extends State<_ScreenshotGallery> {
  // Change this number and hot-restart to switch screens: 0=Tonight, 1=Reader, 2=Library, 3=Settings
  int _currentScreen = 0;

  final _screens = const <Widget>[
    _MockTonightScreen(),
    _MockReaderScreen(),
    _MockLibraryScreen(),
    _MockSettingsScreen(),
  ];

  final _labels = [
    'Tonight',
    'Reader',
    'Library',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentScreen],
      bottomNavigationBar: Container(
        color: AppColors.skyDeep,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_screens.length, (i) {
            final selected = i == _currentScreen;
            return GestureDetector(
              onTap: () => setState(() => _currentScreen = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _labels[i],
                  style: GoogleFonts.nunito(
                    color: selected ? AppColors.skyDeep : AppColors.cream,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Mock Tonight Screen ────────────────────────────────────────

class _MockTonightScreen extends StatelessWidget {
  const _MockTonightScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Night sky gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF060810), AppColors.skyDeep, Color(0xFF0D1229)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('Esta noche', style: GoogleFonts.fraunces(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.cream)),
                  const SizedBox(height: 24),
                  // Story hero card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: ReaderTheme.backgroundGradient,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withAlpha(31)),
                      boxShadow: [BoxShadow(color: AppColors.gold.withAlpha(15), blurRadius: 40)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Theme tags
                        Wrap(
                          spacing: 6,
                          children: ['dinosaurios', 'aventura'].map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.goldDim,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(tag, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.goldLight)),
                          )).toList(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'El dinosaurio que soñaba con volar',
                          style: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.cream, height: 1.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'En un valle escondido entre montañas de cristal, vivía un pequeño dinosaurio llamado Mateo. Cada noche, miraba las estrellas y soñaba con tocar las nubes...',
                          style: GoogleFonts.nunito(fontSize: 14, color: AppColors.cream.withAlpha(179), height: 1.6),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppGradients.goldButton,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [BoxShadow(color: AppColors.gold.withAlpha(77), blurRadius: 24, offset: const Offset(0, 4))],
                      ),
                      child: Center(child: Text('Leer cuento', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.skyDeep))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.cream.withAlpha(64), width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.headphones_rounded, color: AppColors.cream.withAlpha(204), size: 20),
                          const SizedBox(width: 8),
                          Text('Escuchar cuento', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.cream)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_done_rounded, color: AppColors.sage, size: 18),
                      const SizedBox(width: 8),
                      Text('Descargado', style: GoogleFonts.nunito(color: AppColors.sage, fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.nights_stay), label: 'Esta noche'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

// ─── Mock Reader Screen ─────────────────────────────────────────

class _MockReaderScreen extends StatelessWidget {
  const _MockReaderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ReaderTheme.backgroundGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(icon: Icon(Icons.arrow_back, color: AppColors.cream), onPressed: () {}),
                    const Spacer(),
                    IconButton(icon: Icon(Icons.favorite, color: AppColors.terracotta), onPressed: () {}),
                    IconButton(icon: Icon(Icons.cloud_done, color: AppColors.cream.withAlpha(179)), onPressed: () {}),
                    IconButton(icon: Icon(Icons.share_rounded, color: AppColors.cream), onPressed: () {}),
                  ],
                ),
              ),
              // Story content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'El dinosaurio que\nsoñaba con volar',
                          style: ReaderTheme.titleStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'En un valle escondido entre montañas de cristal, vivía un pequeño dinosaurio llamado Mateo. No era el más grande ni el más fuerte, pero tenía algo que ninguno de los otros dinosaurios tenía: un corazón lleno de sueños.\n\nCada noche, cuando las estrellas comenzaban a brillar, Mateo se acostaba en la hierba suave y miraba hacia arriba. Las estrellas le guiñaban como si supieran un secreto.\n\n"Algún día voy a volar hasta allá", susurraba Mateo, mientras sus ojitos se iban cerrando lentamente.\n\nUna noche, algo mágico sucedió. Una estrella dorada bajó del cielo y se posó suavemente en su nariz.',
                        style: ReaderTheme.bodyStyle,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              // Audio player bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: ReaderTheme.playerBackground,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Scrubber
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.gold,
                          inactiveTrackColor: AppColors.cream.withAlpha(61),
                          thumbColor: AppColors.gold,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          trackHeight: 3,
                        ),
                        child: Slider(value: 0.35, onChanged: (_) {}),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('02:14', style: TextStyle(color: AppColors.cream.withAlpha(128), fontSize: 12)),
                            Text('06:30', style: TextStyle(color: AppColors.cream.withAlpha(128), fontSize: 12)),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text('1.0x', style: TextStyle(color: AppColors.cream.withAlpha(179), fontSize: 14)),
                          ),
                          const SizedBox(width: 24),
                          Icon(Icons.pause_circle_filled, color: AppColors.cream, size: 56),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Mock Library Screen ────────────────────────────────────────

class _S {
  final String title, date, tags;
  final bool fav;
  const _S(this.title, this.date, this.tags, this.fav);
}

class _MockLibraryScreen extends StatelessWidget {
  const _MockLibraryScreen();

  static final _stories = [
    _S('El dinosaurio que soñaba con volar', '2 abr', 'dinosaurios, aventura', true),
    _S('La princesa del mar de estrellas', '1 abr', 'princesas, mar', false),
    _S('El robot que aprendió a reír', '31 mar', 'robots, humor', true),
    _S('Viaje a la luna de caramelo', '30 mar', 'espacio, dulces', false),
    _S('El gatito explorador', '29 mar', 'gatos, naturaleza', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF060810), AppColors.skyDeep],
                stops: [0.0, 0.3],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Text('Biblioteca', style: GoogleFonts.fraunces(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.cream)),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.nightBlue,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cream.withAlpha(38)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: AppColors.cream.withAlpha(102), size: 20),
                        const SizedBox(width: 8),
                        Text('Buscar cuentos...', style: GoogleFonts.nunito(color: AppColors.cream.withAlpha(102), fontSize: 15)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _chip('Playlists', false),
                      const SizedBox(width: 8),
                      _chip('Favoritos', true),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Story list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _stories.length,
                    itemBuilder: (context, index) {
                      final s = _stories[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.nightBlue,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.gold.withAlpha(20)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(s.title, style: GoogleFonts.fraunces(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.cream))),
                                if (s.fav) Icon(Icons.favorite, color: AppColors.terracotta, size: 18),
                                const SizedBox(width: 4),
                                Icon(Icons.cloud_done, color: AppColors.sage, size: 16),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(s.date, style: GoogleFonts.nunito(color: AppColors.cream.withAlpha(102), fontSize: 12)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              children: s.tags.split(', ').map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: AppColors.goldDim, borderRadius: BorderRadius.circular(999)),
                                child: Text(t, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.goldLight)),
                              )).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.nights_stay), label: 'Esta noche'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }

  static Widget _chip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.goldDim : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? AppColors.gold.withAlpha(128) : AppColors.cream.withAlpha(38)),
      ),
      child: Text(label, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? AppColors.gold : AppColors.cream.withAlpha(153))),
    );
  }
}

// ─── Mock Settings Screen ───────────────────────────────────────

class _MockSettingsScreen extends StatelessWidget {
  const _MockSettingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF060810), AppColors.skyDeep], stops: [0.0, 0.3]))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('Ajustes', style: GoogleFonts.fraunces(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.cream)),
                  const SizedBox(height: 24),
                  // Profile
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.nightBlue, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gold.withAlpha(31))),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(gradient: AppGradients.goldButton, borderRadius: BorderRadius.circular(999)),
                          child: Center(child: Text('M', style: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.skyDeep))),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mateo', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.cream)),
                            Text('Dinosaurios, azul', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.cream.withAlpha(128))),
                          ],
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right, color: AppColors.cream.withAlpha(102)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader('Suscripción'),
                  _settingsTile(Icons.card_membership, 'Plan Premium', '\$149 MXN/mes'),
                  const SizedBox(height: 16),
                  _sectionHeader('Entrega'),
                  _settingsTile(Icons.schedule, 'Hora de entrega', '8:00 PM'),
                  const SizedBox(height: 16),
                  _sectionHeader('Almacenamiento'),
                  _settingsTile(Icons.storage, '12 cuentos descargados', '24.3 MB'),
                  const SizedBox(height: 16),
                  _sectionHeader('Acerca de'),
                  _settingsTile(Icons.info_outline, 'Versión', '1.0.0'),
                  _settingsTile(Icons.privacy_tip_outlined, 'Aviso de privacidad', ''),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.nights_stay), label: 'Esta noche'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: 'Biblioteca'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }

  static Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: GoogleFonts.fraunces(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.cream.withAlpha(102), letterSpacing: 1)),
          const SizedBox(height: 4),
          Container(height: 1, width: 40, decoration: BoxDecoration(gradient: AppGradients.goldButton, borderRadius: BorderRadius.circular(1))),
        ],
      ),
    );
  }

  static Widget _settingsTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.goldDim, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.gold, size: 20),
        ),
        title: Text(title, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.cream)),
        trailing: subtitle.isNotEmpty ? Text(subtitle, style: GoogleFonts.nunito(fontSize: 13, color: AppColors.cream.withAlpha(128))) : null,
      ),
    );
  }
}
