import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/init_provider.dart';
import '../../core/sync/sync_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/stories_provider.dart';
import '../../theme/app_theme.dart';

class ProfileEditorScreen extends ConsumerStatefulWidget {
  const ProfileEditorScreen({super.key});

  @override
  ConsumerState<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends ConsumerState<ProfileEditorScreen> {
  final _nameController = TextEditingController();
  final _animalController = TextEditingController();
  final _colorController = TextEditingController();
  final _interestController = TextEditingController();
  String? _childId;
  DateTime? _birthdate;
  final List<String> _interests = [];
  bool _saving = false;
  bool _initialized = false;

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
    _nameController.dispose();
    _animalController.dispose();
    _colorController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  void _prefill(dynamic child) {
    if (_initialized || child == null) return;
    _initialized = true;
    _childId = child.id as String;
    _nameController.text = child.name as String? ?? '';
    _animalController.text = child.favoriteAnimal as String? ?? '';
    _colorController.text = child.favoriteColor as String? ?? '';

    // Parse birthdate from 'YYYY-MM-DD' string
    final birthdateStr = child.birthdate as String?;
    if (birthdateStr != null && birthdateStr.isNotEmpty) {
      final parts = birthdateStr.split('-');
      if (parts.length == 3) {
        _birthdate = DateTime(
          int.tryParse(parts[0]) ?? 2020,
          int.tryParse(parts[1]) ?? 1,
          int.tryParse(parts[2]) ?? 1,
        );
      }
    }

    // Parse interests from comma-separated otherInterests field
    final raw = child.otherInterests as String?;
    if (raw != null && raw.isNotEmpty) {
      final parsed = raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
      _interests.addAll(parsed);
    }
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

  Future<void> _save() async {
    final id = _childId;
    if (id == null) return;

    setState(() => _saving = true);
    try {
      final payload = {
        'id': id,
        'name': _nameController.text.trim(),
        'favoriteAnimal': _animalController.text.trim(),
        'favoriteColor': _colorController.text.trim(),
        if (_birthdate != null)
          'birthdate': _birthdate!.toIso8601String().substring(0, 10),
        if (_interests.isNotEmpty)
          'otherInterests': _interests.join(','),
      };
      final isOnline = ref.read(connectivityProvider).value ?? false;
      if (isOnline) {
        final dio = ref.read(apiClientProvider);
        await dio.patch(Endpoints.childrenUpdate, data: payload);
        await ref.read(syncProvider).syncProfile();
      } else {
        await ref.read(pendingActionsProvider).enqueue('profile_edit', payload);
      }
      ref.invalidate(childProfileProvider);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final childAsync = ref.watch(childProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Guardar', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: childAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (child) {
          _prefill(child);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Información del niño',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.cream.withAlpha(128)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: '¿Cómo se llama tu hijo/a?',
                ),
              ),
              const SizedBox(height: 16),

              // Birthdate picker
              GestureDetector(
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
                            ? 'Fecha de nacimiento'
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
              const SizedBox(height: 16),

              TextField(
                controller: _animalController,
                decoration: const InputDecoration(
                  labelText: 'Animal favorito',
                  hintText: 'Perro, gato, dragón...',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color favorito',
                  hintText: 'Azul, rojo, morado...',
                ),
              ),
              const SizedBox(height: 24),

              // Interests section
              Text(
                'Intereses',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.cream.withAlpha(128)),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),

              // Custom interests
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
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _interestController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Agregar otro...',
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

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: const Text('Guardar cambios'),
              ),
            ],
          );
        },
      ),
    );
  }
}
