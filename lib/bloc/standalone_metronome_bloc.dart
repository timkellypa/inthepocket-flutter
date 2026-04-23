import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:in_the_pocket/classes/click_info.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';
import 'package:in_the_pocket/ui/haptics/MetronomeBuzzer.dart';
import 'package:in_the_pocket/ui/listeners/MetronomeClickPlayer.dart';
import 'package:uuid/uuid.dart';
import 'package:wheel_picker/wheel_picker.dart';

class StandaloneMetronomeBloc {
  StandaloneMetronomeBloc() {
    bpmController = WheelPickerController(
      initialIndex: bpmIndex,
      itemCount: 281,
    );
    _clickStateController.sink.add(
      ClickState(count: ClickInfo.SILENCE_COUNT, beatsPerBar: beatsPerBar),
    );

    // Asynchronous, but we don't need to wait.
    // MetronomeSendPort will be available when the isolate is.  Until then,
    // we'll no-op any send port operations.
    registerMetronomeIsolate();
  }

  final StreamController<ClickState> _clickStateController =
      StreamController<ClickState>.broadcast();

  Stream<ClickState> get clickStateStream => _clickStateController.stream;
  MetronomeBuzzer buzzer = MetronomeBuzzer();
  MetronomeClickPlayer player = MetronomeClickPlayer();

  late WheelPickerController bpmController;

  int count = 0;
  int lastTapCount = 0;
  int beatUnit = 4;
  int bpm = 60;
  int accentBeatsPerBar = 1;
  List<int> tapTimes = <int>[];
  bool isolateRegistered = false;
  bool isClicking = false;
  int _beatsPerBar = 4;

  int get beatsPerBar {
    return _beatsPerBar;
  }

  set beatsPerBar(int value) {
    _beatsPerBar = value;

    _clickStateController.sink.add(
      ClickState(count: ClickInfo.SILENCE_COUNT, beatsPerBar: beatsPerBar),
    );
  }

  double get bpmDouble {
    return bpm.toDouble();
  }

  SendPort? metronomeSendPort;
  Isolate? _metronomeIsolateRef;

  /// Create new instance of wheel controller, so we have the right initial value.
  void initializeWheelController() {
    bpmController = WheelPickerController(
      initialIndex: bpmIndex,
      itemCount: 281,
    );
  }

  Future<void> registerMetronomeIsolate() async {
    final ReceivePort receivePort = ReceivePort();

    _metronomeIsolateRef = await Isolate.spawn(
      metronomeIsolate,
      receivePort.sendPort,
    );

    int lastClick = 0;
    final Stopwatch clickDurationStopwatch = Stopwatch();
    clickDurationStopwatch.start();

    receivePort.listen((dynamic message) {
      if (message is SendPort) {
        metronomeSendPort = message;
      } else if (message == 'click') {
        count = (count % beatsPerBar) + 1;

        final Tempo tempo = Tempo(
          bpm: bpmDouble,
          beatsPerBar: beatsPerBar,
          beatUnit: beatUnit,
          accentBeatsPerBar: accentBeatsPerBar,
        );
        final bool accent = TempoRepository.isCountPrimary(tempo, count);

        // Fire haptic and audio right away. Don't wait for UI to process stream.
        // Do haptics in a microtask to allow things to move separately and not compete for main thread.
        player.play(accent);
        Future<void>.microtask(() => buzzer.play(accent));

        final ClickState clickState = ClickState(
          count: count,
          accent: accent,
          beatsPerBar: beatsPerBar,
        );

        if (lastClick != 0) {
          final int currentClick = clickDurationStopwatch.elapsedMicroseconds;
          // Let's do some logging to verify click accuracy.
          final double previousDurationSeconds =
              (currentClick - lastClick) / 1000000.0;
          final double previousClickBpm = 60.0 / previousDurationSeconds;
          print(
            'Previous click duration (seconds) ${previousDurationSeconds.toStringAsFixed(3)}',
          );
          print('Previous click BPM: ${previousClickBpm.toStringAsFixed(3)}');
        }
        lastClick = clickDurationStopwatch.elapsedMicroseconds;

        _clickStateController.sink.add(clickState);
      } else if (message == 'silence') {
        _clickStateController.sink.add(
          ClickState(count: ClickInfo.SILENCE_COUNT, beatsPerBar: beatsPerBar),
        );
      }
    });
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
    }
  }

  set bpmIndex(int index) {
    bpm = index + 20;
    metronomeSendPort?.send(bpmDouble);
  }

  int get bpmIndex {
    return bpm - 20;
  }

  void handlePlay() {
    isClicking = true;

    // Send BPM first, to make it start with correct value.
    metronomeSendPort?.send(bpmDouble);
    metronomeSendPort?.send('start');
  }

  Future<void> metronomeIsolate(SendPort mainSendPort) async {
    final ReceivePort port = ReceivePort();
    mainSendPort.send(port.sendPort);

    final Stopwatch stopwatch = Stopwatch();

    double currentBpm = 120.0;
    double clickDuration = ClickInfo.getClickDurationForBpm(
          currentBpm,
        ) *
        1000;
    String? activeClickLoopId;

    port.listen((dynamic message) {
      if (message is double) {
        currentBpm = message;
        clickDuration = ClickInfo.getClickDurationForBpm(currentBpm) * 1000;
      } else if (message == 'start') {
        if (activeClickLoopId == null) {
          stopwatch
            ..reset()
            ..start();

          activeClickLoopId = const Uuid().v4();

          _runClickLoop(
            () => stopwatch,
            () => currentBpm,
            () => clickDuration,
            () => activeClickLoopId,
            () => mainSendPort.send('click'),
            () => mainSendPort.send('silence'),
          );
        }
      } else if (message == 'stop') {
        activeClickLoopId = null;
      }
    });
  }

  Future<void> _runClickLoop(
    Stopwatch Function() getStopwatch,
    double Function() getBpm,
    double Function() getClickDuration,
    String? Function() getActiveClickLoopId,
    void Function() performClick,
    void Function() performSilence,
  ) async {
    final String thisClickLoopId = getActiveClickLoopId() ?? '';
    double nextClickTime = 0.0;
    double nextSilenceTime = 0.0;
    Stopwatch stopwatch = getStopwatch();
    bool silence = false;
    bool firstIteration = true;

    // Perform this loop while our ID matches the assigned ID from start.
    // If somebody rapidly starts this keeps it so that we only have 1 active loop.
    while (thisClickLoopId == getActiveClickLoopId()) {
      stopwatch = getStopwatch();
      final double currentBpm = getBpm();
      final int now = stopwatch.elapsedMicroseconds;
      final double clickInterval = 60000000 / currentBpm;
      final double clickDuration = getClickDuration();

      // If first iteration, sync up stopwatch, perform a click and continue the loop.
      if (firstIteration) {
        nextClickTime = now + clickInterval;
        nextSilenceTime = now + clickDuration;
        firstIteration = false;
        silence = false;
        performClick();
        firstIteration = false;
      }

      if (now >= nextSilenceTime && !silence) {
        silence = true;
        performSilence();
      }

      if (now >= nextClickTime) {
        performClick();
        silence = false;

        // Calculate next silence time from current click prior to iterating.
        // Anchor to now instead of previous next click
        // to ensure we don't try to catch up a slightly delayed beat.
        nextSilenceTime = now + clickDuration;
        nextClickTime = now + clickInterval;
      }

      // Calculate a next duration time that is:
      // - 1 ms if close to a beat
      // - 5 ms prior to beat
      // - 20 ms max for responsiveness
      final double nextActionTime = min(nextSilenceTime, nextClickTime);
      final double calculatedDuration = nextActionTime - now;
      final int customPollAmount =
          (calculatedDuration - 5000).floor().clamp(1000, 20000);
      final Duration pollingDuration = Duration(microseconds: customPollAmount);
      await Future<void>.delayed(pollingDuration);
    }
  }

  void handlePause() {
    count = 0;
    isClicking = false;
    metronomeSendPort?.send('stop');
    _clickStateController.sink.add(
      ClickState(count: ClickInfo.SILENCE_COUNT, beatsPerBar: beatsPerBar),
    );
  }

  void dispose() {
    _clickStateController.close();
    isClicking = false;
    metronomeSendPort?.send('stop');
    _metronomeIsolateRef?.kill();
    bpmController.dispose();
  }
}
