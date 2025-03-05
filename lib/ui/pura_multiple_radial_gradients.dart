import 'dart:ui';

import 'package:flutter/material.dart';

class PuraMultipleRadialGradients extends StatefulWidget {
  final List<InputPoint> inputPoints;
  final Size? targetSize;
  final double blurRadius;
  final Color backgroundColor;

  const PuraMultipleRadialGradients({
    super.key,
    required this.inputPoints,
    this.targetSize,
    this.blurRadius = 20.0,
    this.backgroundColor = Colors.transparent,
  });

  @override
  _PuraMultipleRadialGradientsState createState() => _PuraMultipleRadialGradientsState();
}

class _PuraMultipleRadialGradientsState extends State<PuraMultipleRadialGradients>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _animations = [];

    for (var point in widget.inputPoints) {
      final controller = AnimationController(
        vsync: this,
        duration: point.animationDuration,
      )..repeat(reverse: true);
      final animation = Tween<double>(
        begin: point.minRelativeRadius,
        end: point.maxRelativeRadius,
      ).animate(controller);
      _controllers.add(controller);
      _animations.add(animation);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.targetSize?.width,
      height: widget.targetSize?.height,
      child: ClipRect(
        child: Stack(
          children: [
            // 最底层：背景颜色
            Container(
              color: widget.backgroundColor,
            ),
            // 中间层：绘制渐变
            ...List.generate(
              widget.inputPoints.length,
              (index) => AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  return CustomPaint(
                    painter: PuraMultipleRadialGradientsPainter(
                      [widget.inputPoints[index]],
                      _animations[index].value,
                      widget.targetSize ?? MediaQuery.of(context).size,
                    ),
                  );
                },
              ),
            ),
            // 最顶层：模糊效果
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: widget.blurRadius,
                sigmaY: widget.blurRadius,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InputPoint {
  final Offset relativeOffset;
  final Color color;
  final double minRelativeRadius;
  final double maxRelativeRadius;
  final Duration animationDuration;

  InputPoint(
    this.relativeOffset,
    this.color,
    this.minRelativeRadius,
    this.maxRelativeRadius,
    this.animationDuration,
  );
}

class PuraMultipleRadialGradientsPainter extends CustomPainter {
  final List<InputPoint> inputPoints;
  final double currentRelativeRadius;
  final Size targetSize;

  PuraMultipleRadialGradientsPainter(
    this.inputPoints,
    this.currentRelativeRadius,
    this.targetSize,
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (var point in inputPoints) {
      // 根据相对坐标和尺寸计算实际坐标
      Offset actualOffset = Offset(
        point.relativeOffset.dx * targetSize.width,
        point.relativeOffset.dy * targetSize.height,
      );
      // 根据当前相对半径和尺寸计算实际半径
      double actualRadius = currentRelativeRadius * (targetSize.shortestSide);

      final gradient = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [point.color.withValues(alpha: 0.8), point.color.withValues(alpha: 0.2)],
      );
      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: actualOffset, radius: actualRadius),
        );
      canvas.drawCircle(actualOffset, actualRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PuraMultipleRadialGradientsPainter oldDelegate) {
    return oldDelegate.currentRelativeRadius != currentRelativeRadius ||
        oldDelegate.inputPoints != inputPoints;
  }
}
