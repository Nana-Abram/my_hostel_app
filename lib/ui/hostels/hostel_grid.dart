import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_hostel_app/backend/provider/filter_provider.dart';
import 'package:my_hostel_app/backend/provider/hostel_provider.dart';
import 'package:my_hostel_app/ui/hostels/hostels_card.dart';
import 'package:my_hostel_app/ui/widgets/modern/modern_widgets.dart';

class HostelGrid extends ConsumerWidget {
  const HostelGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hostelsAsync = ref.watch(hostelsStreamProvider);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return hostelsAsync.when(
      // Loading state - show skeleton loaders
      loading: () => isMobile
          ? Column(
              children: List.generate(
                3,
                (index) => const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: SkeletonHostelCard(),
                ),
              ),
            )
          : Wrap(
              spacing: 20,
              runSpacing: 20,
              children: List.generate(
                6,
                (index) => const SizedBox(
                  width: 300,
                  child: SkeletonHostelCard(),
                ),
              ),
            ),

      // Error state - show error widget with retry
      error: (error, stack) => Center(
        child: NetworkErrorState(
          onRetry: () {
            ref.invalidate(hostelsStreamProvider);
          },
        ),
      ),

      // Data loaded
      data: (hostels) {
        final filteredList = ref.watch(filteredHostelsProvider);

        // Empty state
        if (filteredList.isEmpty) {
          return Center(
            child: EmptyHostelsState(
              onExplore: () {
                ref.read(filterProvider.notifier).clearFilters();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All filters cleared. Showing all hostels.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          );
        }

        // Mobile: one card per row in a Column
        if (isMobile) {
          return Column(
            children: List.generate(filteredList.length, (index) {
              final hostel = filteredList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: StaggeredAnimationWrapper(
                  position: index,
                  animationType: AnimationType.scaleAndFade,
                  child: HostelCard(hostel: hostel),
                ),
              );
            }),
          );
        }

        // Desktop/tablet: Wrap grid
        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: List.generate(filteredList.length, (index) {
            final hostel = filteredList[index];
            return StaggeredAnimationWrapper(
              position: index,
              animationType: AnimationType.scaleAndFade,
              child: HostelCard(hostel: hostel),
            );
          }),
        );
      },
    );
  }
}



