// lib/ui/core/responsive.dart
//
// Single source of truth for all responsive decisions in the app.
// Usage:
//   final r = Responsive.of(context);
//   if (r.isMobile) ...
//   padding: EdgeInsets.symmetric(horizontal: r.pagePadding)
//   fontSize: r.scale(14)   // scales a "design" sp value to the viewport
//
// BREAKPOINTS (matching common device widths):
//   mobile  : < 600
//   tablet  : 600 – 1023
//   desktop : ≥ 1024

import 'package:flutter/material.dart';

class Responsive {
  final double width;
  final double height;

  const Responsive._({required this.width, required this.height});

  factory Responsive.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Responsive._(width: size.width, height: size.height);
  }

  // ── Breakpoints ────────────────────────────────────────────────────────────
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;

  // Convenience
  bool get isNarrow => width < 600;       // mobile
  bool get isMedium => width >= 600 && width < 1024;
  bool get isWide => width >= 1024;

  // ── Page-level horizontal padding ─────────────────────────────────────────
  // Mobile: 16, Tablet: 32, Desktop: max 120 but capped proportionally
  double get pagePadding {
    if (isMobile) return 16;
    if (isTablet) return 32;
    return (width * 0.08).clamp(48, 120);
  }

  // Horizontal padding for card/form containers (narrower than page padding)
  double get cardPadding {
    if (isMobile) return 16;
    if (isTablet) return 24;
    return 32;
  }

  // ── Content max-width (centers content on wide screens) ───────────────────
  double get contentMaxWidth {
    if (isMobile) return double.infinity;
    if (isTablet) return 768;
    return 1200;
  }

  // ── Typography scale ───────────────────────────────────────────────────────
  // Pass your base "design" font size (in sp / logical pixels) and get back
  // a size that scales gracefully across breakpoints.
  double scale(double base) {
    if (isMobile) return base;
    if (isTablet) return base * 1.05;
    return base * 1.1;
  }

  // Heading sizes (H1 → H5)
  double get h1 => scale(isMobile ? 26 : isTablet ? 30 : 36);
  double get h2 => scale(isMobile ? 22 : isTablet ? 26 : 30);
  double get h3 => scale(isMobile ? 18 : isTablet ? 20 : 24);
  double get h4 => scale(isMobile ? 16 : isTablet ? 18 : 20);
  double get h5 => scale(isMobile ? 14 : 16);

  double get bodyLarge => scale(isMobile ? 15 : 16);
  double get body => scale(14);
  double get bodySmall => scale(12);
  double get caption => scale(11);

  // ── Spacing helpers ────────────────────────────────────────────────────────
  double get spacingXS => isMobile ? 4 : 6;
  double get spacingS => isMobile ? 8 : 12;
  double get spacingM => isMobile ? 16 : 20;
  double get spacingL => isMobile ? 24 : 32;
  double get spacingXL => isMobile ? 40 : 56;
  double get spacingXXL => isMobile ? 60 : 80;

  // ── Section vertical padding ───────────────────────────────────────────────
  double get sectionPaddingV => isMobile ? 32 : isTablet ? 48 : 64;

  // ── Grid columns ──────────────────────────────────────────────────────────
  int get gridColumns {
    if (isMobile) return 1;
    if (isTablet) return 2;
    return 3;
  }

  // ── Hero carousel height ──────────────────────────────────────────────────
  double get heroHeight {
    if (isMobile) return 320;
    if (isTablet) return 480;
    return 620;
  }

  // ── AppBar height ─────────────────────────────────────────────────────────
  double get appBarHeight => isMobile ? 64 : 80;

  // ── Auth card constraints ─────────────────────────────────────────────────
  double get authCardMaxWidth {
    if (isMobile) return double.infinity;
    if (isTablet) return 560;
    return 500;
  }

  // ── Drawer / rail ─────────────────────────────────────────────────────────
  bool get useDrawer => isMobile;
  bool get useNavRail => isTablet;
  bool get useNavBar => isDesktop;

  // ── Helpers ───────────────────────────────────────────────────────────────
  /// Wrap content in a centered, max-width constrained box.
  /// Use on page bodies to prevent content stretching on wide screens.
  static Widget constrained({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    final r = Responsive.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? r.contentMaxWidth),
        child: child,
      ),
    );
  }

  /// Builds one layout for mobile and another for tablet/desktop.
  static Widget builder({
    required BuildContext context,
    required Widget Function(Responsive r) mobile,
    Widget Function(Responsive r)? tablet,
    Widget Function(Responsive r)? desktop,
  }) {
    final r = Responsive.of(context);
    if (r.isDesktop && desktop != null) return desktop(r);
    if (r.isTablet && tablet != null) return tablet(r);
    return mobile(r);
  }
}