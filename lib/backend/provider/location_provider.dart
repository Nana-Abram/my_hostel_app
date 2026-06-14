import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_hostel_app/backend/service/location_service.dart';

final locationServiceProvider = Provider<LocationService>((_) => LocationService());

final userLocationProvider = FutureProvider<Position?>((ref) async {
  final service = ref.read(locationServiceProvider);
  return service.getCurrentPosition();
});
