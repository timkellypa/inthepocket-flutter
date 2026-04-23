import 'package:flutter/services.dart';
import 'package:in_the_pocket/classes/click_info.dart';

class MetronomeBuzzer {
  MetronomeBuzzer();

  ClickState? previousState;

  void play(bool accent) {
    if (accent) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }
}
