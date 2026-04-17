import 'dart:async';

import 'package:flutter/services.dart';
import 'package:in_the_pocket/classes/click_info.dart';

class MetronomeBuzzer {
  MetronomeBuzzer({required this.clickStateStream});

  Stream<ClickState> clickStateStream;

  StreamSubscription<ClickState>? clickSubscription;

  ClickState? previousState;

  void listen() {
    clickSubscription = clickStateStream.listen((ClickState clickState) {
      if (clickState.isClicking() && !(previousState?.isClicking() ?? false)) {
        if (clickState.accent) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.mediumImpact();
        }
      }
      previousState = clickState;
    });
  }

  void stopListening() {
    clickSubscription?.cancel();
  }
}
