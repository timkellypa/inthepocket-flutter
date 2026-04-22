import 'dart:async';
import 'dart:isolate';

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

    // Asynchronous, but we don't need to wait.
    // MetronomeSendPort will be available when the isolate is.  Until then,
    // we'll no-op any send port operations.
    registerMetronomeIsolate();
  }

  final StreamController<ClickState> _clickStateController =
      StreamController<ClickState>.broadcast();

  Stream<ClickState> get clickStateStream => _clickStateController.stream;

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
        ClickState(count: ClickInfo.SILENCE_COUNT, beatsPerBar: beatsPerBar));
  }

  double get bpmDouble {
    return bpm.toDouble();
  }

  SendPort? metronomeSendPort;
  Isolate? _metronomeIsolateRef;

  /// Create new instance of wheel controller, so we have the right initial value.
  void initializeWheelController() {
    bpmController =
        WheelPickerController(initialIndex: bpmIndex, itemCount: 281);
  }

  Future<void> registerMetronomeIsolate() async {
    final ReceivePort receivePort = ReceivePort();

    _metronomeIsolateRef =
        await Isolate.spawn(metronomeIsolate, receivePort.sendPort);

    int lastClick = 0;
    final Stopwatch clickDurationStopwatch = Stopwatch();
    clickDurationStopwatch.start();

    receivePort.listen(
      (dynamic message) {
        if (message is SendPort) {
          metronomeSendPort = message;
        } else if (message == 'click') {
          count = (count % beatsPerBar) + 1;

          final Tempo tempo = Tempo(
              bpm: bpmDouble,
              beatsPerBar: beatsPerBar,
              beatUnit: beatUnit,
              accentBeatsPerBar: accentBeatsPerBar);
          final bool accent = TempoRepository.isCountPrimary(tempo, count);
          final ClickState clickState = ClickState(
              count: count, accent: accent, beatsPerBar: beatsPerBar);

          if (lastClick != 0) {
            final int currentClick = clickDurationStopwatch.elapsedMicroseconds;
            // Let's do some logging to verify click accuracy.
            final double previousDurationSeconds =
                (currentClick - lastClick) / 1000000.0;
            final double previousClickBpm = 60.0 / previousDurationSeconds;
            print(
                'Previous click duration (seconds) ${previousDurationSeconds.toStringAsFixed(3)}');
            print('Previous click BPM: ${previousClickBpm.toStringAsFixed(3)}');
          }
          lastClick = clickDurationStopwatch.elapsedMicroseconds;

          _clickStateController.sink.add(clickState);
        } else if (message == 'silence') {
          _clickStateController.sink.add(ClickState(
              count: ClickInfo.SILENCE_COUNT, beatsPerBar: beatsPerBar));
        }
      },
    );
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
    double phaseClickDuration =
        ClickInfo.getClickPhaseDurationForBpm(currentBpm);
    bool running = false;

    port.listen((dynamic message) {
      if (message is double) {
        currentBpm = message;
        phaseClickDuration = ClickInfo.getClickPhaseDurationForBpm(currentBpm);
      } else if (message == 'start') {
        if (!running) {
          stopwatch
            ..reset()
            ..start();
          running = true;
        }
      } else if (message == 'stop') {
        running = false;
      }
    });

    _runClickLoop(
        () => stopwatch,
        () => currentBpm,
        () => phaseClickDuration,
        () => running,
        () => mainSendPort.send('click'),
        () => mainSendPort.send('silence'));
  }

  Future<void> _runClickLoop(
      Stopwatch Function() getStopwatch,
      double Function() getBpm,
      double Function() getPhaseClickDuration,
      bool Function() isRunning,
      void Function() performClick,
      void Function() performSilence) async {
    double beatPhase = 0.0;
    Stopwatch stopwatch = getStopwatch();
    int lastCheck = stopwatch.elapsedMicroseconds;
    bool silence = false;
    bool firstIteration = true;
    const Duration pollingDuration = Duration(microseconds: 500);
    while (true) {
      if (isRunning()) {
        stopwatch = getStopwatch();

        // If first iteration, sync up stopwatch, perform a click and continue the loop.
        if (firstIteration) {
          beatPhase = 0.0;
          firstIteration = false;
          lastCheck = stopwatch.elapsedMicroseconds;
          silence = false;
          performClick();
        }

        final double currentBpm = getBpm();
        final double phaseClickDuration = getPhaseClickDuration();
        final int now = stopwatch.elapsedMicroseconds;
        final int difference = now - lastCheck;

        lastCheck = now;

        beatPhase += (currentBpm * difference) / 60000000;

        while (beatPhase >= 1.0) {
          beatPhase -= 1.0;
          silence = false;
          performClick();
        }

        if (beatPhase >= phaseClickDuration && !silence) {
          silence = true;
          performSilence();
        }
        if (firstIteration) {
          firstIteration = false;
        }
      } else {
        firstIteration = true;
      }

      await Future<void>.delayed(pollingDuration);
    }
  }

  void handlePause() {
    count = 0;
    isClicking = false;
    metronomeSendPort?.send('stop');
    _clickStateController.sink.add(
        ClickState(count: ClickInfo.SILENCE_COUNT, beatsPerBar: beatsPerBar));
  }

  void dispose() {
    _clickStateController.close();
    isClicking = false;
    metronomeSendPort?.send('stop');
    _metronomeIsolateRef?.kill();
    bpmController.dispose();
  }
}
