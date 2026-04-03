import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_provider.dart';
import '../../theme/app_theme.dart';

class MagicLinkSentScreen extends ConsumerStatefulWidget {
  final String email;

  const MagicLinkSentScreen({super.key, required this.email});

  @override
  ConsumerState<MagicLinkSentScreen> createState() => _MagicLinkSentScreenState();
}

class _MagicLinkSentScreenState extends ConsumerState<MagicLinkSentScreen> {
  static const _countdownSeconds = 60;
  int _secondsLeft = _countdownSeconds;
  Timer? _timer;
  bool _resending = false;
  String? _resendMessage;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _countdownSeconds;
      _resendMessage = null;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _resendMessage = null;
    });
    final success = await ref.read(authProvider.notifier).loginWithEmail(widget.email);
    if (!mounted) return;
    setState(() => _resending = false);
    if (success) {
      _startCountdown();
      setState(() => _resendMessage = 'Enlace reenviado.');
    } else {
      setState(() => _resendMessage = 'No pudimos reenviar. Intenta de nuevo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.goldDim,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  size: 56,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Revisa tu correo',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.cream,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enviamos un enlace mágico a',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.cream.withAlpha(153),
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toca el enlace en tu correo para continuar.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.cream.withAlpha(128),
                    ),
              ),
              const SizedBox(height: 48),
              if (_secondsLeft > 0) ...[
                Text(
                  'Reenviar en $_secondsLeft s',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.cream.withAlpha(102),
                      ),
                ),
              ] else ...[
                _resending
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: _resend,
                        child: const Text(
                          'Reenviar enlace',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ],
              if (_resendMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _resendMessage!,
                  style: TextStyle(
                    color: _resendMessage == 'Enlace reenviado.'
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
