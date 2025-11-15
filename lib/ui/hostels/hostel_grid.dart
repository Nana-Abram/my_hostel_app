import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/ui/hostels/hostels_card.dart';

class HostelGrid extends ConsumerWidget {
  const HostelGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This returns a List<HostelModel>
    final filteredList = ref.watch(filteredHostelsProvider);

    return filteredList.isEmpty
        ? const Center(child: Text("No hostels found"))
        : Wrap(
            spacing: 20,
            runSpacing: 20,
            children: filteredList
                .map((hostel) => HostelCard(hostel: hostel))
                .toList(),
          );
  }
}



