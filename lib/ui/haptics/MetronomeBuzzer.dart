import 'package:flutter/services.dart';
import 'package:in_the_pocket/classes/click_info.dart';

class MetronomeBuzzer {
  MetronomeBuzzer();

  ClickState? previousState;

  bool shouldBuzz(int tempo, bool accent) {
    if (tempo > 300) {
      return accent;
    }
    return true;
  }

  void play(int tempo, bool accent) {
    if (!shouldBuzz(tempo, accent)) {
      return;
    }
    if (accent) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }
}
