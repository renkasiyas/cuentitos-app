import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth/auth_provider.dart';
import 'sync/sync_provider.dart';
import 'sync/pending_actions.dart';
import 'notifications/fcm_provider.dart';
import 'api/api_client.dart';
import '../providers/connectivity_provider.dart';
import 'storage/audio_cache.dart';

final pendingActionsProvider = Provider<PendingActionsService>((ref) {
  return PendingActionsService(ref.read(apiClientProvider), ref.read(databaseProvider));
});

final appInitProvider = FutureProvider<void>((ref) async {
  final userState = ref.watch(userStateProvider);
  if (userState != UserState.active && userState != UserState.pastDue) return;

  final isOnline = ref.watch(connectivityProvider).value ?? false;

  if (isOnline) {
    try { await ref.read(syncProvider).fullSync(); } catch (_) {}
    try { await ref.read(fcmProvider).initialize(); } catch (_) {}
    try { await ref.read(pendingActionsProvider).flushAll(); } catch (_) {}
  }

  await AudioCache.pruneOlderThan(const Duration(days: 30));
});

/// Watches connectivity changes and flushes pending actions when reconnected.
final connectivityFlushProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
    final wasOffline = previous?.value == false;
    final isNowOnline = next.value == true;
    if (wasOffline && isNowOnline) {
      ref.read(pendingActionsProvider).flushAll();
      ref.read(syncProvider).fullSync();
    }
  });
});
