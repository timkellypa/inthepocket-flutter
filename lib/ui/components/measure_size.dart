import 'package:flutter/material.dart';

class MeasureSize extends StatefulWidget {
  const MeasureSize({
    required this.onChange,
    required this.child,
  });

  final ValueChanged<Size> onChange;
  final Widget child;

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  final GlobalKey<State<MeasureSize>> _widgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
          _widgetKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        widget.onChange(renderBox.size);
      }
    });

    return SizedBox(
      key: _widgetKey,
      child: widget.child,
    );
  }
}
