import 'dart:async';

import 'package:flutter/services.dart';
import 'package:in_the_pocket/bloc/metronome_indicator_state_bloc.dart';

class MetronomeBuzzer {
  MetronomeBuzzer({required this.bloc});

  MetronomeIndicatorStateBloc bloc;

  StreamSubscription<ClickState>? clickSubscription;

  ClickState? previousState;

  void listen() {
    clickSubscription = bloc.clickStateStream.listen((ClickState clickState) {
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
