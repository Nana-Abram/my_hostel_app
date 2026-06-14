import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/backend/provider/location_provider.dart';

class HostelsMapView extends ConsumerStatefulWidget {
  const HostelsMapView({super.key});

  @override
  ConsumerState<HostelsMapView> createState() => _HostelsMapViewState();
}

class _HostelsMapViewState extends ConsumerState<HostelsMapView> {
  GoogleMapController? _mapController;
  HostelModel? _selectedHostel;

  static const _defaultCenter = CameraPosition(
    target: LatLng(5.6037, -0.1870), // Accra, Ghana
    zoom: 8,
  );

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers(List<HostelModel> hostels) {
    return hostels
        .where((h) => h.latitude != null && h.longitude != null)
        .map(
          (h) => Marker(
            markerId: MarkerId(h.id),
            position: LatLng(h.latitude!, h.longitude!),
            infoWindow: InfoWindow(
              title: h.name,
              snippet: 'GHS ${h.startPrice.toStringAsFixed(0)}/semester',
            ),
            onTap: () => setState(() => _selectedHostel = h),
          ),
        )
        .toSet();
  }

  void _fitBoundsToMarkers(List<HostelModel> mappable) {
    if (_mapController == null || mappable.isEmpty) return;

    double minLat = mappable.first.latitude!;
    double maxLat = mappable.first.latitude!;
    double minLng = mappable.first.longitude!;
    double maxLng = mappable.first.longitude!;

    for (final h in mappable) {
      if (h.latitude! < minLat) minLat = h.latitude!;
      if (h.latitude! > maxLat) maxLat = h.latitude!;
      if (h.longitude! < minLng) minLng = h.longitude!;
      if (h.longitude! > maxLng) maxLng = h.longitude!;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.02, minLng - 0.02),
          northeast: LatLng(maxLat + 0.02, maxLng + 0.02),
        ),
        60,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hostels = ref.watch(filteredHostelsProvider);
    final userLocationAsync = ref.watch(userLocationProvider);

    final mappableHostels =
        hostels.where((h) => h.latitude != null && h.longitude != null).toList();

    final userPos = userLocationAsync.asData?.value;
    final initialPosition = userPos != null
        ? CameraPosition(target: LatLng(userPos.latitude, userPos.longitude), zoom: 12)
        : _defaultCenter;

    if (mappableHostels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64.sp,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            SizedBox(height: 16.h),
            Text(
              'No hostel locations on map yet',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Text(
                'Hostel owners can add GPS coordinates\nwhen creating or editing their hostel.',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initialPosition,
          markers: _buildMarkers(hostels),
          onMapCreated: (controller) {
            _mapController = controller;
            _fitBoundsToMarkers(mappableHostels);
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          onTap: (_) => setState(() => _selectedHostel = null),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Text(
              '${mappableHostels.length} hostel${mappableHostels.length != 1 ? 's' : ''} on map',
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (_selectedHostel != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _HostelMapCard(
              hostel: _selectedHostel!,
              onClose: () => setState(() => _selectedHostel = null),
            ),
          ),
      ],
    );
  }
}

class _HostelMapCard extends StatelessWidget {
  const _HostelMapCard({required this.hostel, required this.onClose});

  final HostelModel hostel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: hostel.images.isNotEmpty
                  ? Image.network(
                      hostel.images.first,
                      width: 80.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(theme),
                    )
                  : _placeholder(theme),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hostel.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          hostel.campus,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'From GHS ${hostel.startPrice.toStringAsFixed(0)}/semester',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.close, size: 16.sp, color: theme.colorScheme.onSurfaceVariant),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.h),
                ),
                SizedBox(height: 4.h),
                FilledButton(
                  onPressed: () => GoRouter.of(context).push('/hostel-details/${hostel.id}'),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    minimumSize: Size.zero,
                  ),
                  child: Text('View', style: TextStyle(fontSize: 12.sp)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Container(
      width: 80.w,
      height: 80.h,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(Icons.hotel, color: theme.colorScheme.onSurfaceVariant),
    );
  }
}
