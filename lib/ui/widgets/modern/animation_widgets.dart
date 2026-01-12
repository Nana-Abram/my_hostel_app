import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// Wrapper widget that adds pull-to-refresh functionality to any scrollable content
class PullToRefreshWrapper extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;

  const PullToRefreshWrapper({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? Theme.of(context).primaryColor,
      child: child,
    );
  }
}

/// Custom refresh indicator with better styling
class CustomRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? backgroundColor;
  final Color? color;
  final double strokeWidth;

  const CustomRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.backgroundColor,
    this.color,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: backgroundColor ?? theme.cardColor,
      color: color ?? theme.primaryColor,
      strokeWidth: strokeWidth,
      child: child,
    );
  }
}

/// Animated list with staggered animation effect
class AnimatedListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Duration duration;
  final double horizontalOffset;
  final double verticalOffset;

  const AnimatedListView({
    super.key,
    required this.children,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.duration = const Duration(milliseconds: 375),
    this.horizontalOffset = 50.0,
    this.verticalOffset = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: padding,
        physics: physics,
        shrinkWrap: shrinkWrap,
        itemCount: children.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: duration,
            child: SlideAnimation(
              verticalOffset: verticalOffset,
              child: FadeInAnimation(
                child: children[index],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Animated grid with staggered animation effect
class AnimatedGridView extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Duration duration;
  final double childAspectRatio;

  const AnimatedGridView({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.duration = const Duration(milliseconds: 375),
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: GridView.builder(
        padding: padding,
        physics: physics,
        shrinkWrap: shrinkWrap,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: duration,
            columnCount: crossAxisCount,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: children[index],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Wrapper for adding staggered animation to any widget
class StaggeredAnimationWrapper extends StatelessWidget {
  final Widget child;
  final int position;
  final Duration duration;
  final AnimationType animationType;

  const StaggeredAnimationWrapper({
    super.key,
    required this.child,
    required this.position,
    this.duration = const Duration(milliseconds: 375),
    this.animationType = AnimationType.slideAndFade,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: position,
      duration: duration,
      child: _buildAnimatedChild(),
    );
  }

  Widget _buildAnimatedChild() {
    switch (animationType) {
      case AnimationType.slide:
        return SlideAnimation(child: child);
      case AnimationType.fade:
        return FadeInAnimation(child: child);
      case AnimationType.scale:
        return ScaleAnimation(child: child);
      case AnimationType.slideAndFade:
        return SlideAnimation(
          child: FadeInAnimation(child: child),
        );
      case AnimationType.scaleAndFade:
        return ScaleAnimation(
          child: FadeInAnimation(child: child),
        );
    }
  }
}

enum AnimationType {
  slide,
  fade,
  scale,
  slideAndFade,
  scaleAndFade,
}

/// Custom page transition animations
class CustomPageRoute<T> extends MaterialPageRoute<T> {
  final PageTransitionType transitionType;

  CustomPageRoute({
    required super.builder,
    super.settings,
    this.transitionType = PageTransitionType.fade,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (transitionType) {
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );

      case PageTransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case PageTransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case PageTransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );

      case PageTransitionType.fadeAndSlide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
  }
}

enum PageTransitionType {
  fade,
  slide,
  scale,
  rotation,
  slideUp,
  fadeAndSlide,
}

/// Helper function to navigate with custom animation
void navigateWithAnimation(
  BuildContext context,
  Widget page, {
  PageTransitionType transitionType = PageTransitionType.fadeAndSlide,
  bool replace = false,
}) {
  final route = CustomPageRoute(
    builder: (context) => page,
    transitionType: transitionType,
  );

  if (replace) {
    Navigator.pushReplacement(context, route);
  } else {
    Navigator.push(context, route);
  }
}
