import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Custom loading indicators with various styles
class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;
  final LoadingStyle style;

  const LoadingIndicator({
    super.key,
    this.color,
    this.size = 50.0,
    this.style = LoadingStyle.fadingCircle,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorColor = color ?? Theme.of(context).primaryColor;

    switch (style) {
      case LoadingStyle.circle:
        return SpinKitCircle(
          color: indicatorColor,
          size: size,
        );
      case LoadingStyle.fadingCircle:
        return SpinKitFadingCircle(
          color: indicatorColor,
          size: size,
        );
      case LoadingStyle.wave:
        return SpinKitWave(
          color: indicatorColor,
          size: size,
        );
      case LoadingStyle.threeBounce:
        return SpinKitThreeBounce(
          color: indicatorColor,
          size: size,
        );
      case LoadingStyle.pulse:
        return SpinKitPulse(
          color: indicatorColor,
          size: size,
        );
      case LoadingStyle.doubleBounce:
        return SpinKitDoubleBounce(
          color: indicatorColor,
          size: size,
        );
      case LoadingStyle.ripple:
        return SpinKitRipple(
          color: indicatorColor,
          size: size,
        );
      case LoadingStyle.fadingFour:
        return SpinKitFadingFour(
          color: indicatorColor,
          size: size,
        );
    }
  }
}

enum LoadingStyle {
  circle,
  fadingCircle,
  wave,
  threeBounce,
  pulse,
  doubleBounce,
  ripple,
  fadingFour,
}

/// Full-screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isLoading;
  final Widget child;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    this.message,
    required this.isLoading,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? 
              Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LoadingIndicator(
                    color: Colors.white,
                    style: LoadingStyle.fadingCircle,
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Card with loading state
class LoadingCard extends StatelessWidget {
  final double? width;
  final double? height;
  final String? message;

  const LoadingCard({
    super.key,
    this.width,
    this.height = 200,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicator(
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Button with loading state
class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final IconData? icon;

  const LoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
