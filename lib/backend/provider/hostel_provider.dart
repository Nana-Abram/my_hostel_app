import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/provider/filter_provider.dart';
import 'package:my_hostel_app/backend/service/hostel_service.dart';

final hostelServiceProvider = Provider((ref) => HostelService());

// Live updates are better for listings:
final hostelsStreamProvider = StreamProvider<List<HostelModel>>((ref) {
  final service = ref.read(hostelServiceProvider);
  return service.watchAllHostels(); // implement as a Firestore snapshots() stream
});

final filteredHostelsProvider =
    Provider<List<HostelModel>>((ref) {
  final filter = ref.watch(filterProvider);
  final hostelsAsync = ref.watch(hostelsStreamProvider);

  return hostelsAsync.maybeWhen(
    data: (hostels) {
      return hostels.where((h) {
        final campusOk = (filter.campus == null || filter.campus!.isEmpty)
            ? true
            : h.campus == filter.campus;

        final priceOk = (filter.maxPrice == null)
            ? true
            : h.startPrice <= filter.maxPrice!;

        final amenitiesOk = filter.amenities.isEmpty
            ? true
            : filter.amenities.every(h.amenities.contains);

        return campusOk && priceOk && amenitiesOk;
      }).toList();
    },
    orElse: () => const <HostelModel>[],
  );
});
