import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/ui/hostels/hostels_card.dart';

class HostelGrid extends ConsumerWidget {
  const HostelGrid({super.key});

 
  @override
Widget build(BuildContext context, WidgetRef ref) {
  final hostels = ref.watch(filteredHostelsProvider);

  if (hostels.isEmpty) {
    return const Center(child: Text("No hostels match your filters"));
  }

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Wrap(
      // direction: Axis.vertical,
      spacing: 20,
      runSpacing: 20,
      children: hostels
          .map((hostel) => HostelCard(hostel: hostel))
          .toList(),
    ),
  );

}

}
