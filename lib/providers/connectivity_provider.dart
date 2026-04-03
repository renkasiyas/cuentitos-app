import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) async* {
  // Emit initial state immediately
  final initial = await Connectivity().checkConnectivity();
  yield initial.any((r) => r != ConnectivityResult.none);

  // Then stream changes
  await for (final results in Connectivity().onConnectivityChanged) {
    yield results.any((r) => r != ConnectivityResult.none);
  }
});
