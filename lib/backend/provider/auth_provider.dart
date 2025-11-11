import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/service/auth_service.dart';


final authServiceProvider = Provider((ref) => AuthService());

final loginProvider =
    FutureProvider.family((ref, Map<String, String> credentials) {
  final service = ref.read(authServiceProvider);
  return service.login(
    credentials["email"]!,
    credentials["password"]!,
  );
});


final registerProvider =
    FutureProvider.family((ref, Map<String, String> data) {
  final service = ref.read(authServiceProvider);
  return service.registerUser(
    data["email"]!,
    data["password"]!,
    data["name"]!,
  );
});
