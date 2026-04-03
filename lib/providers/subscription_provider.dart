import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'child_provider.dart';

final subscriptionTierProvider = Provider<String>((ref) {
  final parent = ref.watch(parentProfileProvider).value;
  return parent?.subscriptionTier ?? 'basico';
});

final subscriptionStatusProvider = Provider<String>((ref) {
  final parent = ref.watch(parentProfileProvider).value;
  return parent?.subscriptionStatus ?? 'pending';
});

final isActiveSubscriberProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionStatusProvider) == 'active';
});

final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionTierProvider) == 'premium' && ref.watch(isActiveSubscriberProvider);
});
