import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  static const _totalPages = 6;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // Page 0: child name
  final _nameController = TextEditingController();

  // Page 1: birthdate
  DateTime? _birthdate;

  // Page 2: gender
  String? _gender; // 'nino' | 'nina'

  // Page 3: favorite animal
  final _animalController = TextEditingController();

  // Page 4: favorite color
  final _colorController = TextEditingController();

  // Page 5: interests
  final List<String> _interests = [];
  final _interestController = TextEditingController();

  static const _suggestedInterests = [
    'dinosaurios',
    'princesas',
    'robots',
    'magia',
    'aventura',
    'piratas',
    'animales',
    'música',
    'deportes',
    'ciencia',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _animalController.dispose();
    _colorController.dispose();
    _interestController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    switch (_currentPage) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return _birthdate != null;
      case 2:
        return _gender != null;
      case 3:
        return _animalController.text.trim().isNotEmpty;
      case 4:
        return _colorController.text.trim().isNotEmpty;
      case 5:
        return _interests.isNotEmpty;
      default:
        return false;
    }
  }

  void _animateIn() {
    _fadeController.reset();
    _slideController.reset();
    _fadeController.forward();
    _slideController.forward();
  }

  void _next() {
    if (!_canProceed) return;
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _complete() {
    final quizData = <String, dynamic>{
      'childName': _nameController.text.trim(),
      'birthdate': _birthdate!.toIso8601String().substring(0, 10),
      'gender': _gender,
      'favoriteAnimal': _animalController.text.trim(),
      'favoriteColor': _colorController.text.trim(),
      'interests': List<String>.from(_interests),
    };
    context.go('/tier', extra: quizData);
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final fourYearsAgo = DateTime(now.year - 4, now.month, now.day);
    final tenYearsAgo = DateTime(now.year - 10, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? fourYearsAgo,
      firstDate: tenYearsAgo,
      lastDate: now,
      helpText: 'Fecha de nacimiento',
      locale: const Locale('es', 'MX'),
    );
    if (picked != null) {
      setState(() => _birthdate = picked);
    }
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_interests.contains(interest)) {
        _interests.remove(interest);
      } else {
        _interests.add(interest);
      }
    });
  }

  void _addCustomInterest() {
    final val = _interestController.text.trim().toLowerCase();
    if (val.isNotEmpty && !_interests.contains(val)) {
      setState(() {
        _interests.add(val);
        _interestController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skyDeep,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.cream, size: 20),
                onPressed: _back,
              )
            : null,
        title: _StarTrailProgress(current: _currentPage + 1, total: _totalPages),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.nightSky),
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (page) {
            setState(() => _currentPage = page);
            _animateIn();
          },
          children: [
            _buildNamePage(),
            _buildBirthdatePage(),
            _buildGenderPage(),
            _buildAnimalPage(),
            _buildColorPage(),
            _buildInterestsPage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, AppColors.skyDeep],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
            child: _QuizGoldButton(
              text: _currentPage < _totalPages - 1 ? 'Siguiente' : 'Ver planes',
              onPressed: _canProceed ? _next : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return _PageWrapper(
      title: '¿Cómo se llama tu hijo/a?',
      fadeAnimation: _fadeAnimation,
      slideAnimation: _slideAnimation,
      child: TextField(
        controller: _nameController,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        style: GoogleFonts.nunito(color: AppColors.cream, fontSize: 16),
        decoration: const InputDecoration(
          labelText: 'Nombre',
          hintText: 'Ej: Sofía',
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildBirthdatePage() {
    return _PageWrapper(
      title: '¿Cuándo nació ${_nameController.text.trim().isNotEmpty ? _nameController.text.trim() : "tu hijo/a"}?',
      fadeAnimation: _fadeAnimation,
      slideAnimation: _slideAnimation,
      child: GestureDetector(
        onTap: _pickBirthdate,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.nightBlue,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _birthdate != null ? AppColors.gold : AppColors.cream.withAlpha(38),
              width: _birthdate != null ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: AppColors.gold),
              const SizedBox(width: 12),
              Text(
                _birthdate == null
                    ? 'Seleccionar fecha'
                    : '${_birthdate!.day}/${_birthdate!.month}/${_birthdate!.year}',
                style: GoogleFonts.nunito(
                  color: _birthdate == null ? AppColors.cream.withAlpha(128) : AppColors.cream,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderPage() {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'tu hijo/a';
    return _PageWrapper(
      title: '¿$name es…?',
      fadeAnimation: _fadeAnimation,
      slideAnimation: _slideAnimation,
      child: Row(
        children: [
          Expanded(
            child: _GenderCard(
              label: 'Niño',
              icon: Icons.boy,
              selected: _gender == 'nino',
              onTap: () => setState(() => _gender = 'nino'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _GenderCard(
              label: 'Niña',
              icon: Icons.girl,
              selected: _gender == 'nina',
              onTap: () => setState(() => _gender = 'nina'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalPage() {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'tu hijo/a';
    return _PageWrapper(
      title: '¿Cuál es el animal favorito de $name?',
      fadeAnimation: _fadeAnimation,
      slideAnimation: _slideAnimation,
      child: TextField(
        controller: _animalController,
        textCapitalization: TextCapitalization.sentences,
        style: GoogleFonts.nunito(color: AppColors.cream, fontSize: 16),
        decoration: const InputDecoration(
          labelText: 'Animal favorito',
          hintText: 'Ej: dragón, perro, delfín…',
          prefixIcon: Icon(Icons.pets),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildColorPage() {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'tu hijo/a';
    return _PageWrapper(
      title: '¿Cuál es el color favorito de $name?',
      fadeAnimation: _fadeAnimation,
      slideAnimation: _slideAnimation,
      child: TextField(
        controller: _colorController,
        textCapitalization: TextCapitalization.sentences,
        style: GoogleFonts.nunito(color: AppColors.cream, fontSize: 16),
        decoration: const InputDecoration(
          labelText: 'Color favorito',
          hintText: 'Ej: azul, morado, dorado…',
          prefixIcon: Icon(Icons.palette_outlined),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildInterestsPage() {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'tu hijo/a';
    return _PageWrapper(
      title: '¿Qué le gusta a $name?',
      subtitle: 'Elige los que apliquen o agrega los tuyos.',
      fadeAnimation: _fadeAnimation,
      slideAnimation: _slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedInterests.map((interest) {
              final selected = _interests.contains(interest);
              return GestureDetector(
                onTap: () => _toggleInterest(interest),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.goldDim : AppColors.nightBlue,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected ? AppColors.gold : AppColors.cream.withAlpha(38),
                      width: selected ? 1.5 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.gold.withAlpha(50),
                              blurRadius: 8,
                              spreadRadius: 0,
                            )
                          ]
                        : null,
                  ),
                  child: Text(
                    interest,
                    style: GoogleFonts.nunito(
                      color: selected ? AppColors.gold : AppColors.cream.withAlpha(179),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Custom interests chips
          if (_interests.any((i) => !_suggestedInterests.contains(i))) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _interests
                  .where((i) => !_suggestedInterests.contains(i))
                  .map((i) => Chip(
                        label: Text(
                          i,
                          style: GoogleFonts.nunito(color: AppColors.gold, fontSize: 13),
                        ),
                        backgroundColor: AppColors.goldDim,
                        side: const BorderSide(color: AppColors.gold, width: 1),
                        deleteIconColor: AppColors.gold,
                        onDeleted: () => setState(() => _interests.remove(i)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _interestController,
                  textCapitalization: TextCapitalization.sentences,
                  style: GoogleFonts.nunito(color: AppColors.cream, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Agregar otro…',
                    isDense: true,
                  ),
                  onSubmitted: (_) => _addCustomInterest(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.gold),
                onPressed: _addCustomInterest,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Star Trail Progress ───────────────────────────────────────

class _StarTrailProgress extends StatelessWidget {
  final int current;
  final int total;

  const _StarTrailProgress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final filled = i < current;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              height: 3,
              decoration: BoxDecoration(
                gradient: filled
                    ? const LinearGradient(
                        colors: [AppColors.gold, AppColors.goldLight],
                      )
                    : null,
                color: filled ? null : AppColors.cream.withAlpha(30),
                borderRadius: BorderRadius.circular(2),
                boxShadow: filled
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withAlpha(100),
                          blurRadius: 6,
                          spreadRadius: 0,
                        )
                      ]
                    : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Page Wrapper ─────────────────────────────────────────────

class _PageWrapper extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const _PageWrapper({
    required this.title,
    this.subtitle,
    required this.child,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 100, 28, 24),
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.fraunces(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                  height: 1.25,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.cream.withAlpha(153),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Gender Card ──────────────────────────────────────────────

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: selected ? AppColors.goldDim : AppColors.nightBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.cream.withAlpha(38),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withAlpha(60),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: selected ? AppColors.gold : AppColors.cream.withAlpha(100)),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: selected ? AppColors.gold : AppColors.cream,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quiz Gold Button ─────────────────────────────────────────

class _QuizGoldButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;

  const _QuizGoldButton({required this.text, this.onPressed});

  @override
  State<_QuizGoldButton> createState() => _QuizGoldButtonState();
}

class _QuizGoldButtonState extends State<_QuizGoldButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed!();
            }
          : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        transform: Matrix4.diagonal3Values(
          _pressed ? 0.98 : 1.0, _pressed ? 0.98 : 1.0, 1.0)
          ..setTranslationRaw(0.0, _pressed ? -1.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF5A623), Color(0xFFE89B1C)],
                )
              : null,
          color: enabled ? null : AppColors.cream.withAlpha(20),
          borderRadius: BorderRadius.circular(999),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.gold.withAlpha(_pressed ? 50 : 77),
                    blurRadius: _pressed ? 16 : 24,
                    offset: Offset(0, _pressed ? 2 : 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            widget.text,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: enabled ? AppColors.skyDeep : AppColors.cream.withAlpha(80),
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
    );
  }
}
