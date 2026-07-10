import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:health_sphere/core/theme/app_colors.dart';

/// Production-grade full-screen loading overlay.
///
/// When [isLoading] is true:
///  - ALL pointer events on the ENTIRE screen are absorbed (form fields,
///    buttons, scrolling — everything is disabled).
///  - The content beneath is blurred with [BackdropFilter].
///  - A centered, glassy spinner card fades in with a smooth animation.
///
/// Usage:
/// ```dart
/// LoadingOverlay(
///   isLoading: _isLoading,
///   child: YourScreenContent(),
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  /// Blur intensity applied to the background. Default: 6.
  final double blurSigma;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.blurSigma = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    // AbsorbPointer wraps the ENTIRE Stack so that when isLoading=true,
    // NO touch event can reach the child content (fields, buttons, etc.).
    return AbsorbPointer(
      absorbing: isLoading,
      child: Stack(
        children: [
          // ── Main content ──────────────────────────────────────────────
          child,

          // ── Overlay (animates in/out) ─────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: isLoading
                ? _OverlayLayer(
                    key: const ValueKey('overlay'),
                    blurSigma: blurSigma,
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }
}

// ── Private overlay layer ─────────────────────────────────────────────────────

class _OverlayLayer extends StatefulWidget {
  final double blurSigma;

  const _OverlayLayer({super.key, required this.blurSigma});

  @override
  State<_OverlayLayer> createState() => _OverlayLayerState();
}

class _OverlayLayerState extends State<_OverlayLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ClipRect(
        child: BackdropFilter(
          // ── Blur the background ──────────────────────────────────────
          filter: ImageFilter.blur(
            sigmaX: widget.blurSigma,
            sigmaY: widget.blurSigma,
          ),
          child: Container(
            color: Colors.black.withValues(alpha: 0.30),
            alignment: Alignment.center,
            child: ScaleTransition(
              scale: _pulseAnim,
              child: const _SpinnerCard(),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Premium spinner card ──────────────────────────────────────────────────────

class _SpinnerCard extends StatelessWidget {
  const _SpinnerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 40,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 42,
          height: 42,
          child: CircularProgressIndicator(
            strokeWidth: 3.5,
            strokeCap: StrokeCap.round,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
      ),
    );
  }
}
