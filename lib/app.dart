import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'core/init_provider.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/login_screen.dart';
import 'features/onboarding/magic_link_sent_screen.dart';
import 'features/onboarding/quiz_screen.dart';
import 'features/onboarding/tier_screen.dart';
import 'features/onboarding/checkout_screen.dart';
import 'features/onboarding/waiting_screen.dart';
import 'features/tonight/tonight_screen.dart';
import 'features/reader/reader_screen.dart';
import 'features/library/library_screen.dart';
import 'features/library/playlist_detail_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/profile_editor_screen.dart';
import 'features/settings/subscription_screen.dart';
import 'core/auth/auth_provider.dart';

final _onboardingPaths = [
  '/welcome',
  '/login',
  '/magic-link-sent',
  '/quiz',
  '/tier',
  '/checkout',
  '/waiting',
  '/auth/mobile',
];

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/tonight',
    redirect: (context, state) {
      final isOnboarding =
          _onboardingPaths.any((p) => state.matchedLocation.startsWith(p));

      // While auth is resolving, don't redirect
      if (authState == AuthState.unknown) return null;

      if (authState == AuthState.unauthenticated && !isOnboarding) {
        return '/welcome';
      }
      if (authState == AuthState.authenticated &&
          state.matchedLocation == '/welcome') {
        return '/tonight';
      }
      return null;
    },
    routes: [
      // Onboarding
      GoRoute(
          path: '/welcome', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: '/magic-link-sent',
          builder: (_, state) => MagicLinkSentScreen(
              email: state.uri.queryParameters['email'] ?? '')),
      GoRoute(path: '/quiz', builder: (_, __) => const QuizScreen()),
      GoRoute(
          path: '/tier',
          builder: (_, state) =>
              TierScreen(quizData: state.extra as Map<String, dynamic>)),
      GoRoute(
          path: '/checkout',
          builder: (_, state) => CheckoutScreen(
              onboardData: state.extra as Map<String, dynamic>)),
      GoRoute(
          path: '/waiting', builder: (_, __) => const WaitingScreen()),

      // Main app (shell with bottom nav)
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/tonight',
                builder: (_, __) => const TonightScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/library',
                builder: (_, __) => const LibraryScreen()),
            GoRoute(
                path: '/library/playlist/:id',
                builder: (_, state) => PlaylistDetailScreen(
                    playlistId: state.pathParameters['id']!)),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/settings',
                builder: (_, __) => const SettingsScreen()),
            GoRoute(
                path: '/settings/profile',
                builder: (_, __) => const ProfileEditorScreen()),
            GoRoute(
                path: '/settings/subscription',
                builder: (_, __) => const SubscriptionScreen()),
          ]),
        ],
      ),

      // Story reader (full-screen overlay)
      GoRoute(
          path: '/reader/:id',
          builder: (_, state) =>
              ReaderScreen(storyId: state.pathParameters['id']!)),

      // Deep link handler
      GoRoute(
        path: '/auth/mobile',
        builder: (_, state) => _MagicLinkVerifier(
          code: state.uri.queryParameters['code'] ?? '',
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
    ],
  );
});

class _MagicLinkVerifier extends ConsumerStatefulWidget {
  final String code;
  final String email;
  const _MagicLinkVerifier({required this.code, required this.email});

  @override
  ConsumerState<_MagicLinkVerifier> createState() =>
      _MagicLinkVerifierState();
}

class _MagicLinkVerifierState extends ConsumerState<_MagicLinkVerifier> {
  bool _verifying = true;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    final success = await ref
        .read(authProvider.notifier)
        .verifyMagicLink(widget.code, widget.email);
    if (!mounted) return;
    if (success) {
      context.go('/tonight');
    } else {
      setState(() {
        _verifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_verifying) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Enlace expirado o invalido'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Solicitar nuevo enlace'),
          ),
        ],
      )),
    );
  }
}

class _MainShell extends ConsumerWidget {
  final StatefulNavigationShell shell;
  const _MainShell({required this.shell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appInitProvider); // Trigger sync on mount
    ref.watch(connectivityFlushProvider); // Flush pending actions on reconnect
    return Scaffold(
      body: shell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: shell.currentIndex,
        onTap: shell.goBranch,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.nights_stay), label: 'Esta noche'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books), label: 'Biblioteca'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

class CuentitosApp extends ConsumerWidget {
  const CuentitosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Cuentitos',
      theme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
