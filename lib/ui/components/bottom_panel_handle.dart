import 'package:flutter/material.dart';

class BottomPanelHandle extends StatelessWidget {
  const BottomPanelHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.onSurface;

    return Semantics(
        label: 'Drag Handle',
        child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Center(
              child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999))),
            )));
  }
}
