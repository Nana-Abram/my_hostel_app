import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_hostel_app/backend/model/hostel_model.dart';

class HostelMapWidget extends ConsumerStatefulWidget {
  const HostelMapWidget({super.key, required this.hostel});

  final HostelModel hostel;

  @override
  ConsumerState<HostelMapWidget> createState() => _HostelMapWidgetState();
}

class _HostelMapWidgetState extends ConsumerState<HostelMapWidget> {
  GoogleMapController? _mapController;

  LatLng? get _hostelLatLng {
    if (widget.hostel.latitude != null && widget.hostel.longitude != null) {
      return LatLng(widget.hostel.latitude!, widget.hostel.longitude!);
    }
    return null;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _openDirections() async {
    final latLng = _hostelLatLng;
    final Uri uri;
    if (latLng != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${latLng.latitude},${latLng.longitude}',
      );
    } else {
      final query = Uri.encodeComponent('${widget.hostel.name}, ${widget.hostel.campus}');
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Set<Marker> _buildMarkers(LatLng hostelLatLng) {
    return {
      Marker(
        markerId: const MarkerId('hostel'),
        position: hostelLatLng,
        infoWindow: InfoWindow(
          title: widget.hostel.name,
          snippet: widget.hostel.campus,
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latLng = _hostelLatLng;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.dividerColor, width: 0.5.w),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(Icons.location_on, color: theme.colorScheme.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _openDirections,
                  icon: Icon(Icons.directions, size: 16.sp),
                  label: Text('Directions', style: TextStyle(fontSize: 12.sp)),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                ),
              ],
            ),
          ),
          if (latLng != null)
            SizedBox(
              height: 500.h,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: latLng, zoom: 15),
                markers: _buildMarkers(latLng),
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
            )
          else
            _buildFallback(theme),
        ],
      ),
    );
  }

  Widget _buildFallback(ThemeData theme) {
    return Container(
      height: 160.h,
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 40.sp,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 8.h),
          Text(
            widget.hostel.campus,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            widget.hostel.location,
            style: TextStyle(
              fontSize: 12.sp,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            'No precise coordinates added yet',
            style: TextStyle(
              fontSize: 11.sp,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
