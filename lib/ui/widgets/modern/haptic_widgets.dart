import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// Haptic feedback utility class
class HapticUtils {
  /// Light haptic feedback for simple interactions
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback for standard interactions
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback for important interactions
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection feedback (light click)
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate for success actions
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
  }

  /// Vibrate for error actions
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }

  /// Vibrate for warning actions
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
  }

  /// Custom vibration pattern (Android only)
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}

/// Button with haptic feedback on tap
class HapticButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final HapticFeedbackType feedbackType;
  final ButtonStyle? style;

  const HapticButton({
    super.key,
    required this.child,
    this.onPressed,
    this.feedbackType = HapticFeedbackType.light,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed != null
          ? () async {
              await _performHapticFeedback();
              onPressed!();
            }
          : null,
      style: style,
      child: child,
    );
  }

  Future<void> _performHapticFeedback() async {
    switch (feedbackType) {
      case HapticFeedbackType.light:
        await HapticUtils.lightImpact();
        break;
      case HapticFeedbackType.medium:
        await HapticUtils.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        await HapticUtils.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        await HapticUtils.selectionClick();
        break;
    }
  }
}

/// Icon button with haptic feedback
class HapticIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final HapticFeedbackType feedbackType;
  final Color? color;
  final double? size;
  final String? tooltip;

  const HapticIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.feedbackType = HapticFeedbackType.light,
    this.color,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: size),
      color: color,
      tooltip: tooltip,
      onPressed: onPressed != null
          ? () async {
              await _performHapticFeedback();
              onPressed!();
            }
          : null,
    );
  }

  Future<void> _performHapticFeedback() async {
    switch (feedbackType) {
      case HapticFeedbackType.light:
        await HapticUtils.lightImpact();
        break;
      case HapticFeedbackType.medium:
        await HapticUtils.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        await HapticUtils.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        await HapticUtils.selectionClick();
        break;
    }
  }
}

/// Gesture detector with haptic feedback
class HapticGestureDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;
  final HapticFeedbackType feedbackType;
  final bool enableHapticOnTap;
  final bool enableHapticOnDoubleTap;
  final bool enableHapticOnLongPress;

  const HapticGestureDetector({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.feedbackType = HapticFeedbackType.light,
    this.enableHapticOnTap = true,
    this.enableHapticOnDoubleTap = true,
    this.enableHapticOnLongPress = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null
          ? () async {
              if (enableHapticOnTap) {
                await _performHapticFeedback();
              }
              onTap!();
            }
          : null,
      onDoubleTap: onDoubleTap != null
          ? () async {
              if (enableHapticOnDoubleTap) {
                await _performHapticFeedback();
              }
              onDoubleTap!();
            }
          : null,
      onLongPress: onLongPress != null
          ? () async {
              if (enableHapticOnLongPress) {
                await HapticUtils.heavyImpact();
              }
              onLongPress!();
            }
          : null,
      child: child,
    );
  }

  Future<void> _performHapticFeedback() async {
    switch (feedbackType) {
      case HapticFeedbackType.light:
        await HapticUtils.lightImpact();
        break;
      case HapticFeedbackType.medium:
        await HapticUtils.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        await HapticUtils.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        await HapticUtils.selectionClick();
        break;
    }
  }
}

/// Card with haptic feedback on tap
class HapticCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final HapticFeedbackType feedbackType;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;

  const HapticCard({
    super.key,
    required this.child,
    this.onTap,
    this.feedbackType = HapticFeedbackType.light,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: elevation,
      margin: margin,
      shape: shape,
      child: InkWell(
        onTap: onTap != null
            ? () async {
                await _performHapticFeedback();
                onTap!();
              }
            : null,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  Future<void> _performHapticFeedback() async {
    switch (feedbackType) {
      case HapticFeedbackType.light:
        await HapticUtils.lightImpact();
        break;
      case HapticFeedbackType.medium:
        await HapticUtils.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        await HapticUtils.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        await HapticUtils.selectionClick();
        break;
    }
  }
}

/// List tile with haptic feedback
class HapticListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final HapticFeedbackType feedbackType;

  const HapticListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.feedbackType = HapticFeedbackType.light,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap != null
          ? () async {
              await _performHapticFeedback();
              onTap!();
            }
          : null,
      onLongPress: onLongPress != null
          ? () async {
              await HapticUtils.heavyImpact();
              onLongPress!();
            }
          : null,
    );
  }

  Future<void> _performHapticFeedback() async {
    switch (feedbackType) {
      case HapticFeedbackType.light:
        await HapticUtils.lightImpact();
        break;
      case HapticFeedbackType.medium:
        await HapticUtils.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        await HapticUtils.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        await HapticUtils.selectionClick();
        break;
    }
  }
}

enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}
