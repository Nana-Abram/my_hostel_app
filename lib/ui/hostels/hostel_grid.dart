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
      loading: () => SingleChildScrollView(
        child: isMobile
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

        // Mobile: lazy list — only builds/lays out cards near the viewport
        // instead of constructing every card up front (the previous Column
        // + List.generate built the whole list eagerly on every filter change).
        if (isMobile) {
          return AnimatedListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              for (final hostel in filteredList)
                Padding(
                  key: ValueKey(hostel.id),
                  padding: const EdgeInsets.only(bottom: 16),
                  child: HostelCard(hostel: hostel),
                ),
            ],
          );
        }

        // Desktop/tablet: Wrap grid. Cards have content-driven (non-uniform)
        // heights, so a true lazy SliverGrid isn't a safe drop-in replacement
        // here without forcing a fixed aspect ratio — kept as Wrap for now.
        return SingleChildScrollView(
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: List.generate(filteredList.length, (index) {
              final hostel = filteredList[index];
              return StaggeredAnimationWrapper(
                key: ValueKey(hostel.id),
                position: index,
                animationType: AnimationType.scaleAndFade,
                child: HostelCard(hostel: hostel),
              );
            }),
          ),
        );
      },
    );
  }
}



