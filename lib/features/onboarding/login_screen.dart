import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';
import '../../core/sync/sync_provider.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  bool _loadingEmail = false;
  bool _loadingGoogle = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendMagicLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Ingresa tu correo electrónico');
      return;
    }
    setState(() {
      _loadingEmail = true;
      _error = null;
    });
    final success = await ref.read(authProvider.notifier).loginWithEmail(email);
    if (!mounted) return;
    setState(() => _loadingEmail = false);
    if (success) {
      context.go('/magic-link-sent?email=${Uri.encodeComponent(email)}');
    } else {
      setState(() => _error = 'No pudimos enviar el enlace. Intenta de nuevo.');
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loadingGoogle = true;
      _error = null;
    });
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      final account = await googleSignIn.signIn();
      if (account == null) {
        setState(() => _loadingGoogle = false);
        return;
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        setState(() {
          _loadingGoogle = false;
          _error = 'No se pudo obtener el token de Google.';
        });
        return;
      }
      final success = await ref.read(authProvider.notifier).loginWithGoogle(idToken);
      if (!mounted) return;
      setState(() => _loadingGoogle = false);
      if (success) {
        try {
          final dio = ref.read(apiClientProvider);
          final response = await dio.get(Endpoints.me);
          if (!mounted) return;
          final child = response.data['child'];
          final parent = response.data['parent'] as Map<String, dynamic>?;
          final subscriptionStatus = parent?['subscriptionStatus'] as String?;
          if (child != null && subscriptionStatus == 'active') {
            await ref.read(syncProvider).fullSync();
            if (mounted) context.go('/tonight');
          } else {
            if (mounted) context.go('/quiz');
          }
        } catch (_) {
          if (mounted) context.go('/quiz');
        }
      } else {
        setState(() => _error = 'No pudimos iniciar sesión con Google. Intenta de nuevo.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingGoogle = false;
        _error = 'Google Sign-In no esta disponible. Usa tu correo electronico.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _loadingEmail || _loadingGoogle;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Ingresa a Cuentitos',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.cream,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Te enviaremos un enlace mágico a tu correo.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.cream.withAlpha(153),
                    ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'tu@correo.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : _sendMagicLink,
                child: _loadingEmail
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.skyDeep,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Enviar enlace mágico'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'o',
                      style: TextStyle(color: AppColors.cream.withAlpha(128)),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: isLoading ? null : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3C4043),
                    side: const BorderSide(color: Color(0xFFDADCE0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: _loadingGoogle
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4285F4)),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/google_logo.svg',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Continuar con Google',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF3C4043),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
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
