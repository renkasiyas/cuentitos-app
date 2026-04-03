import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';

class ParentProfile {
  final String id;
  final String email;
  final String? phone;
  final String? name;
  final String subscriptionTier;
  final String subscriptionStatus;
  final int deliveryHour;

  ParentProfile({
    required this.id, required this.email, this.phone, this.name,
    required this.subscriptionTier, required this.subscriptionStatus,
    required this.deliveryHour,
  });

  factory ParentProfile.fromJson(Map<String, dynamic> json) => ParentProfile(
    id: json['id'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String?,
    name: json['name'] as String?,
    subscriptionTier: json['subscriptionTier'] as String? ?? 'basico',
    subscriptionStatus: json['subscriptionStatus'] as String? ?? 'pending',
    deliveryHour: json['deliveryHour'] as int? ?? 18,
  );
}

final parentProfileProvider = FutureProvider<ParentProfile?>((ref) async {
  final dio = ref.read(apiClientProvider);
  try {
    final response = await dio.get(Endpoints.me);
    return ParentProfile.fromJson(response.data['parent'] as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
});
