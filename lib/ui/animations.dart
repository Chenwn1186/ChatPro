import 'package:flutter/material.dart';

class FadeInParent extends StatefulWidget {
  final Widget child;

  const FadeInParent({super.key, required this.child});

  @override
  _FadeInParentState createState() => _FadeInParentState();
}

class _FadeInParentState extends State<FadeInParent> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // 在组件创建后，逐渐增加透明度
    Future.delayed(const Duration(milliseconds: 100), () {
      // 检查组件是否已经挂载
      if (mounted) { 
        setState(() {
          _opacity = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 500), // 动画持续时间
      child: widget.child,
    );
  }
}