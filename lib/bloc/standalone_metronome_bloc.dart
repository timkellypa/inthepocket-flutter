import 'dart:async';

import 'package:in_the_pocket/classes/click_info.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
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
      performClick(fromTap: true);
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

    // Perform a single click immediately.  It will start an interval for the next one.
    performClick();
  }

  void performClick({bool fromTap = false}) {
    if (!isClicking) {
      clickTimer?.cancel();
      clickTimer = null;
      return;
    }

    if (fromTap && count != lastTapCount) {
      // If this click was triggered by a tap, and the count is the same as the last tap, don't perform the click.
      // It was already done.
      lastTapCount = count;
      return;
    }

    count = (count % beatsPerBar) + 1;

    if (fromTap) {
      lastTapCount = count;
    }

    final Tempo tempo = Tempo(
        bpm: bpm.toDouble(),
        beatsPerBar: beatsPerBar,
        beatUnit: beatUnit,
        accentBeatsPerBar: accentBeatsPerBar);

    final ClickInfo clickInfo = ClickInfo(
        count: count,
        tempo: tempo,
        duration: ClickInfo.getClickDurationForTempo(tempo).toDouble());

    _clickStateController.sink.add(ClickState(
        count: count, accent: clickInfo.accent, beatsPerBar: beatsPerBar));

    clickDurationTimer?.cancel();

    clickDurationTimer =
        Timer(Duration(milliseconds: clickInfo.duration.round()), finishClick);

    final double millisecondsPerBeat = 60000 / bpm;
    clickTimer?.cancel();
    clickTimer = Timer(
        Duration(milliseconds: millisecondsPerBeat.round()), performClick);
  }

  void finishClick() {
    _clickStateController.sink.add(
        ClickState(count: ClickInfo.SILENCE_COUNT, beatsPerBar: beatsPerBar));
  }

  void handlePause() {
    count = 0;
    isClicking = false;
  }

  void dispose() {
    _clickStateController.close();
    isClicking = false;
    clickTimer?.cancel();
    clickDurationTimer?.cancel();
    bpmController.dispose();
  }
}
