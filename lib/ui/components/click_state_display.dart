import 'package:flutter/material.dart';
import 'package:in_the_pocket/classes/click_info.dart';
import 'package:led_bulb_indicator/led_bulb_indicator.dart';

class ClickStateDisplay extends StatelessWidget {
  const ClickStateDisplay({required this.clickState});

  final ClickState clickState;

  @override
  Widget build(BuildContext context) {
    const LedBulbColors inactiveColor = LedBulbColors.off,
        accentColor = LedBulbColors.green,
        clickColor = LedBulbColors.red;
    const double size = 30;

    final List<Widget> indicators = List<Widget>.empty(growable: true);

    for (int i = 1; i <= clickState.beatsPerBar; ++i) {
      LedBulbColors color = inactiveColor;
      bool glow = false;
      if (i == clickState.count) {
        glow = true;
        if (clickState.accent) {
          color = accentColor;
        } else {
          color = clickColor;
        }
      }
      indicators
          .add(LedBulbIndicator(size: size, initialState: color, glow: glow));
    }

    return Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            key: const Key('ClickIndicatorRow'),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: indicators));
  }
}
