import 'dart:async';

import 'package:in_the_pocket/classes/click_info.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';
import 'package:wheel_picker/wheel_picker.dart';

class StandaloneMetronomeBloc {
  StandaloneMetronomeBloc() {
    bpmController =
        WheelPickerController(initialIndex: bpmIndex, itemCount: 281);
    _clickStateController.sink.add(
        ClickState(count: ClickInfo.SILENCE_COUNT, beatsPerBar: beatsPerBar));
  }

  final StreamController<ClickState> _clickStateController =
      StreamController<ClickState>.broadcast();

  Stream<ClickState> get clickStateStream => _clickStateController.stream;

  late WheelPickerController bpmController;

  int get beatsPerBar {
    return _beatsPerBar;
  }

  set beatsPerBar(int value) {
    _beatsPerBar = value;

    _clickStateController.sink.add(
        ClickState(count: ClickInfo.SILENCE_COUNT, beatsPerBar: beatsPerBar));
  }

  bool isClicking = false;
  int count = 0;
  int lastTapCount = 0;
  int beatUnit = 4;
  int bpm = 60;
  int accentBeatsPerBar = 1;
  List<int> tapTimes = <int>[];

  // Click start time.  When this is null, it means a click hasn't started yet.
  int? clickStartTime;

  // Time when previous click started.
  // Used for logging to verify accuracy.
  int? previousClickStart;

  int _beatsPerBar = 4;

  /// Create new instance of wheel controller, so we have the right initial value.
  void initializeWheelController() {
    bpmController =
        WheelPickerController(initialIndex: bpmIndex, itemCount: 281);
  }

  void handleTap() {
    // If last tap was more than 2 seconds ago, clear taps and start over.
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (tapTimes.isNotEmpty && tapTimes[tapTimes.length - 1] < now - 2000) {
      tapTimes.clear();
    }

    tapTimes.add(DateTime.now().millisecondsSinceEpoch);

    if (tapTimes.length >= 3) {
      // average the last 3 taps to get a BPM.
      final int lastTapTime = tapTimes.last;
      final int thirdLastTapTime = tapTimes[tapTimes.length - 3];
      final int averageTimeBetweenTaps = (lastTapTime - thirdLastTapTime) ~/ 2;
      bpm = (60000 / averageTimeBetweenTaps).round();
      bpmController.shiftTo(bpmIndex);
      nextClickState(fromTap: true);
    }
  }

  set bpmIndex(int index) {
    bpm = index + 20;
  }

  int get bpmIndex {
    return bpm - 20;
  }

  void handlePlay() {
    isClicking = true;
    clickStartTime = null;

    // Perform a single click immediately.  It will start an interval for the next one.
    nextClickState();
  }

  void nextClickState({bool fromTap = false}) {
    if (!isClicking) {
      return;
    }

    if (fromTap && (count != lastTapCount || clickStartTime != null)) {
      // If this click was triggered by a tap, and the count is the same as the last tap, don't perform the click.
      // It was already done.
      lastTapCount = count;
      return;
    }

    if (fromTap) {
      clickStartTime = null;
    }

    final double bpmDouble = bpm.toDouble();

    final Tempo tempo = Tempo(
        bpm: bpmDouble,
        beatsPerBar: beatsPerBar,
        beatUnit: beatUnit,
        accentBeatsPerBar: accentBeatsPerBar);

    if (clickStartTime == null) {
      count = (count % beatsPerBar) + 1;

      if (fromTap) {
        lastTapCount = count;
      }

      // Null click start time means that we should be performing the actual click here.
      clickStartTime = DateTime.now().microsecondsSinceEpoch;

      final bool isPrimary = TempoRepository.isCountPrimary(tempo, count);
      final ClickState clickState =
          ClickState(count: count, accent: isPrimary, beatsPerBar: beatsPerBar);

      if (previousClickStart != null) {
        final double previousDurationSeconds =
            (clickStartTime! - previousClickStart!) / 1000000.0;
        final double previousClickBpm = 60.0 / previousDurationSeconds;
        print(
            'Previous click duration (seconds) ${previousDurationSeconds.toStringAsFixed(3)}');
        print('Previous click BPM: ${previousClickBpm.toStringAsFixed(3)}');
      }

      previousClickStart = clickStartTime;
      final int clickDuration =
          ClickInfo.getClickDurationForBpm(bpmDouble) * 1000;
      Future<void>.delayed(
          Duration(microseconds: clickDuration), nextClickState);

      _clickStateController.sink.add(clickState);
    } else {
      final int now = DateTime.now().microsecondsSinceEpoch;
      final int timerDurationOffset = now - (clickStartTime ?? now);

      final int timerDuration =
          ((60000000 / (bpm + bpm * 1 / 120)) - timerDurationOffset).round();
      clickStartTime = null;
      Future<void>.delayed(
          Duration(microseconds: timerDuration), nextClickState);
      // Schedule next click and stop this one
      _clickStateController.sink.add(
          ClickState(count: ClickInfo.SILENCE_COUNT, beatsPerBar: beatsPerBar));
    }
  }

  void handlePause() {
    count = 0;
    clickStartTime = null;
    previousClickStart = null;
    _clickStateController.sink.add(
        ClickState(count: ClickInfo.SILENCE_COUNT, beatsPerBar: beatsPerBar));
    isClicking = false;
  }

  void dispose() {
    _clickStateController.close();
    isClicking = false;
    clickStartTime = null;
    bpmController.dispose();
  }
}
