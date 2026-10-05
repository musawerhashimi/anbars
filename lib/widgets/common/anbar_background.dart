import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// App-wide backdrop: soft mint→ice gradient with glowing green / blue / red
/// orbs and a faint dot texture that fades out down the page.
class AnbarBackground extends StatelessWidget {
  final Widget child;
  const AnbarBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final base = isDark
        ? const [Color(0xFF0A1511), Color(0xFF0B1220), Color(0xFF0A0E16)]
        : const [Color(0xFFE8F7EE), Color(0xFFEEF4FF), Color(0xFFF7F9FC)];

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: base,
                    stops: const [0, 0.45, 1],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              _Orb(
                center: const Alignment(-1.1, -1.05),
                radius: 1.0,
                color: AppColors.primary,
                opacity: isDark ? 0.22 : 0.20,
              ),
              _Orb(
                center: const Alignment(1.25, -0.35),
                radius: 0.95,
                color: AppColors.secondary,
                opacity: isDark ? 0.20 : 0.16,
              ),
              _Orb(
                center: const Alignment(-1.2, 1.1),
                radius: 0.9,
                color: AppColors.accent,
                opacity: isDark ? 0.10 : 0.07,
              ),
              _Orb(
                center: const Alignment(1.1, 1.15),
                radius: 0.8,
                color: AppColors.primary,
                opacity: isDark ? 0.10 : 0.08,
              ),
              ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.transparent],
                  stops: [0, 0.45],
                ).createShader(rect),
                child: CustomPaint(
                  painter: _DotGridPainter(
                    color: (isDark ? Colors.white : AppColors.secondary)
                        .withValues(alpha: isDark ? 0.05 : 0.07),
                  ),
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  final Alignment center;
  final double radius;
  final Color color;
  final double opacity;

  const _Orb({
    required this.center,
    required this.radius,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: center,
          radius: radius,
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.4),
            color.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final Color color;
  const _DotGridPainter({required this.color});

  static const _gap = 22.0;
  static const _dot = 1.2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var y = _gap / 2; y < size.height; y += _gap) {
      for (var x = _gap / 2; x < size.width; x += _gap) {
        canvas.drawCircle(Offset(x, y), _dot, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.color != color;
}

/// Wraps every pushed page in [AnbarBackground] so each route stays opaque
/// during transitions while scaffolds themselves are transparent.
class AnbarPageTransitionsBuilder extends PageTransitionsBuilder {
  final PageTransitionsBuilder inner;
  const AnbarPageTransitionsBuilder(this.inner);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return inner.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      AnbarBackground(child: child),
    );
  }
}
