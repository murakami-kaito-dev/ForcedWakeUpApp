import 'package:flutter/material.dart';
import '../models/badge_type.dart';

class BadgeWidget extends StatefulWidget {
  final BadgeType badge;
  final bool unlocked;
  final bool isLatest;
  final double size;

  const BadgeWidget({
    super.key,
    required this.badge,
    required this.unlocked,
    this.isLatest = false,
    this.size = 64,
  });

  @override
  State<BadgeWidget> createState() => _BadgeWidgetState();
}

class _BadgeWidgetState extends State<BadgeWidget>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.unlocked) {
      _shimmerController.repeat();
    }
    if (widget.isLatest) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final iconSize = size * 0.5;

    Widget badge = AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return CustomPaint(
          painter: widget.unlocked
              ? _ShimmerBadgePainter(
                  colors: widget.badge.gradientColors,
                  shimmerProgress: _shimmerController.value,
                )
              : null,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: widget.unlocked
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFFBDBDBD), Color(0xFF9E9E9E)],
                    ),
              border: widget.isLatest
                  ? Border.all(color: widget.badge.color, width: 3)
                  : null,
            ),
            child: Icon(
              widget.badge.icon,
              size: iconSize,
              color: widget.unlocked ? Colors.white : const Color(0xFF757575),
            ),
          ),
        );
      },
    );

    if (widget.isLatest) {
      badge = ScaleTransition(scale: _pulseAnimation, child: badge);
    }

    return badge;
  }
}

class _ShimmerBadgePainter extends CustomPainter {
  final List<Color> colors;
  final double shimmerProgress;

  _ShimmerBadgePainter({
    required this.colors,
    required this.shimmerProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Base gradient circle
    final basePaint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePaint);

    // Shimmer overlay
    final shimmerX = -radius + (size.width + radius * 2) * shimmerProgress;
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.35),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromLTWH(shimmerX - radius * 0.6, 0, radius * 1.2, size.height),
      );

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      shimmerPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShimmerBadgePainter oldDelegate) =>
      shimmerProgress != oldDelegate.shimmerProgress;
}
