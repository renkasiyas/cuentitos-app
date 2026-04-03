import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  static const _totalPages = 6;

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
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _animalController.dispose();
    _colorController.dispose();
    _interestController.dispose();
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _back,
              )
            : null,
        title: _ProgressBar(current: _currentPage + 1, total: _totalPages),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          _buildNamePage(),
          _buildBirthdatePage(),
          _buildGenderPage(),
          _buildAnimalPage(),
          _buildColorPage(),
          _buildInterestsPage(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
          child: ElevatedButton(
            onPressed: _canProceed ? _next : null,
            child: Text(_currentPage < _totalPages - 1 ? 'Siguiente' : 'Ver planes'),
          ),
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return _PageWrapper(
      title: '¿Cómo se llama tu hijo/a?',
      child: TextField(
        controller: _nameController,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
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
      child: GestureDetector(
        onTap: _pickBirthdate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.nightBlue,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cream.withAlpha(38)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: AppColors.gold),
              const SizedBox(width: 12),
              Text(
                _birthdate == null
                    ? 'Seleccionar fecha'
                    : '${_birthdate!.day}/${_birthdate!.month}/${_birthdate!.year}',
                style: TextStyle(
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
      child: TextField(
        controller: _animalController,
        textCapitalization: TextCapitalization.sentences,
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
      child: TextField(
        controller: _colorController,
        textCapitalization: TextCapitalization.sentences,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedInterests.map((interest) {
              final selected = _interests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: selected,
                onSelected: (_) => _toggleInterest(interest),
                selectedColor: AppColors.goldDim,
                checkmarkColor: AppColors.gold,
                labelStyle: TextStyle(
                  color: selected ? AppColors.gold : AppColors.cream.withAlpha(179),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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
                        label: Text(i),
                        backgroundColor: AppColors.goldDim,
                        labelStyle: const TextStyle(color: AppColors.gold),
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

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final filled = i < current;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            decoration: BoxDecoration(
              color: filled ? AppColors.gold : AppColors.goldDim,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _PageWrapper extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _PageWrapper({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.cream,
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.cream.withAlpha(153),
                  ),
            ),
          ],
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }
}

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
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: selected ? AppColors.goldDim : AppColors.nightBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.cream.withAlpha(38),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: selected ? AppColors.gold : AppColors.cream.withAlpha(128)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.gold : AppColors.cream,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
