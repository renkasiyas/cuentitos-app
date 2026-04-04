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

// ─── Page Transitions ───────────────────────────────────────────

/// Crossfade — for tab switches, auth redirects, screens with built-in entrance animations
CustomTransitionPage<void> _fade(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Slide from right — forward navigation in a flow
CustomTransitionPage<void> _slideForward(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(curve),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

/// Slide up from bottom — modal overlays (reader, checkout)
CustomTransitionPage<void> _slideUp(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curve),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: const Interval(0, 0.5)),
          child: child,
        ),
      );
    },
  );
}

// ─── Router ─────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final userState = ref.watch(userStateProvider);

  return GoRouter(
    initialLocation: '/tonight',
    redirect: (context, state) {
      final loc = state.matchedLocation;

      if (userState == UserState.unknown) return null;

      if (userState == UserState.anonymous) {
        if (['/welcome', '/login', '/magic-link-sent', '/auth/mobile'].any((p) => loc.startsWith(p))) return null;
        return '/welcome';
      }

      if (userState == UserState.lead || userState == UserState.onboarding) {
        if (['/quiz', '/tier', '/checkout', '/waiting'].any((p) => loc.startsWith(p))) return null;
        return '/quiz';
      }

      if (userState == UserState.unpaid) {
        if (['/tier', '/checkout', '/waiting'].any((p) => loc.startsWith(p))) return null;
        return '/tier';
      }

      // active, pastDue, canceled — allow main app + tier/checkout for resubscribe
      if (['/welcome', '/login', '/magic-link-sent', '/quiz'].any((p) => loc.startsWith(p))) {
        return '/tonight';
      }
      return null;
    },
    routes: [
      // Onboarding — fade transitions (each screen has its own entrance animations)
      GoRoute(
        path: '/welcome',
        pageBuilder: (_, __) => _fade(const OnboardingScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (_, __) => _slideForward(const LoginScreen()),
      ),
      GoRoute(
        path: '/magic-link-sent',
        pageBuilder: (_, state) => _fade(MagicLinkSentScreen(
            email: state.uri.queryParameters['email'] ?? '')),
      ),
      GoRoute(
        path: '/quiz',
        pageBuilder: (_, __) => _slideForward(const QuizScreen()),
      ),
      GoRoute(
        path: '/tier',
        pageBuilder: (_, state) => _slideForward(
            TierScreen(quizData: state.extra as Map<String, dynamic>?)),
      ),
      GoRoute(
        path: '/checkout',
        pageBuilder: (_, state) => _slideUp(CheckoutScreen(
            onboardData: state.extra as Map<String, dynamic>)),
      ),
      GoRoute(
        path: '/waiting',
        pageBuilder: (_, __) => _fade(const WaitingScreen()),
      ),

      // Main app (shell with bottom nav) — tabs fade, no slide
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tonight',
              pageBuilder: (_, __) => _fade(const TonightScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/library',
              pageBuilder: (_, __) => _fade(const LibraryScreen()),
            ),
            GoRoute(
              path: '/library/playlist/:id',
              pageBuilder: (_, state) => _slideForward(PlaylistDetailScreen(
                  playlistId: state.pathParameters['id']!)),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (_, __) => _fade(const SettingsScreen()),
            ),
            GoRoute(
              path: '/settings/profile',
              pageBuilder: (_, __) => _slideForward(const ProfileEditorScreen()),
            ),
            GoRoute(
              path: '/settings/subscription',
              pageBuilder: (_, __) => _slideForward(const SubscriptionScreen()),
            ),
          ]),
        ],
      ),

      // Story reader — slides up from bottom (modal overlay feel)
      GoRoute(
        path: '/reader/:id',
        pageBuilder: (_, state) => _slideUp(
            ReaderScreen(storyId: state.pathParameters['id']!)),
      ),

      // Deep link handler — instant, no animation
      GoRoute(
        path: '/auth/mobile',
        pageBuilder: (_, state) => _fade(_MagicLinkVerifier(
          code: state.uri.queryParameters['code'] ?? '',
          email: state.uri.queryParameters['email'] ?? '',
        )),
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
        .read(userStateProvider.notifier)
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
    final userState = ref.watch(userStateProvider);
    ref.watch(appInitProvider); // Trigger sync on mount
    ref.watch(connectivityFlushProvider); // Flush pending actions on reconnect

    // Show loading while auth is resolving
    if (userState == UserState.unknown) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

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
