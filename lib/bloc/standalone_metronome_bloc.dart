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

  int _beatsPerBar = 4;

  // single instance of timer that we can cancel and restart as needed.
  Timer? clickTimer;
  Timer? clickDurationTimer;

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
      clickTimer?.cancel();
      clickTimer = null;
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

    clickTimer?.cancel();

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
      clickStartTime = DateTime.now().millisecondsSinceEpoch;

      final bool isPrimary = TempoRepository.isCountPrimary(tempo, count);
      final ClickState clickState =
          ClickState(count: count, accent: isPrimary, beatsPerBar: beatsPerBar);

      _clickStateController.sink.add(clickState);
      final int clickDuration = ClickInfo.getClickDurationForBpm(bpmDouble);
      clickTimer = Timer(Duration(milliseconds: clickDuration), nextClickState);
    } else {
      final int now = DateTime.now().millisecondsSinceEpoch;
      final int timerDurationOffset = now - (clickStartTime ?? now);

      if (timerDurationOffset == 0) {
        // a null click startTime at the last minute means a tap has interfered with this thread.
        // Return in this state, so the tap handles everything.
        return;
      }

      // Stop this click and schedule the next one, based on the difference between the calculated time and clickStartTime
      _clickStateController.sink.add(
          ClickState(count: ClickInfo.SILENCE_COUNT, beatsPerBar: beatsPerBar));

      final int timerDuration = (60000 / bpm).round() - timerDurationOffset;
      clickStartTime = null;
      clickTimer?.cancel();
      clickTimer = Timer(Duration(milliseconds: timerDuration), nextClickState);
    }
  }

  void handlePause() {
    count = 0;
    clickTimer?.cancel();
    clickTimer = null;
    clickStartTime = null;
    _clickStateController.sink.add(
        ClickState(count: ClickInfo.SILENCE_COUNT, beatsPerBar: beatsPerBar));
    isClicking = false;
  }

  void dispose() {
    _clickStateController.close();
    isClicking = false;
    clickStartTime = null;
    clickTimer?.cancel();
    clickDurationTimer?.cancel();
    bpmController.dispose();
  }
}
