import 'dart:math';

import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';

class ClickInfo {
  ClickInfo({required this.duration, required this.count, this.tempo});

  static const int SILENCE_COUNT = -1;

  bool get silence {
    return count == SILENCE_COUNT;
  }

  bool get accent {
    if (tempo == null) {
      return false;
    }
    return TempoRepository.isCountPrimary(tempo!, count);
  }

  /// Note, count of 0 means we are out of range.
  int count;
  Tempo? tempo;
  double duration;

  static int getClickDurationForBpm(double bpm) {
    return min(100, (60 / bpm * 1000 - 10).round());
  }
}

class ClickState {
  ClickState({required this.count, this.accent = false, this.beatsPerBar = 4});

  bool isClicking() {
    return count != ClickInfo.SILENCE_COUNT;
  }

  bool accent;
  int count;
  int beatsPerBar;
}
