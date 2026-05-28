import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:in_the_pocket/audio/setlist_audio_handler.dart';
import 'package:in_the_pocket/classes/click_info.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';
import 'package:in_the_pocket/services/service_locator.dart';
import 'package:in_the_pocket/ui/haptics/MetronomeBuzzer.dart';
import 'package:rxdart/rxdart.dart';

class MetronomeIndicatorStateBloc {
  MetronomeIndicatorStateBloc() {
    _clickStateController.sink.add(ClickState(count: 0));
    timer.start();
    startListening();
  }

  final SetlistAudioHandler _audioHandler = getIt<SetlistAudioHandler>();

  StreamSubscription<Duration?>? _positionSubscription;

  int anchorTime = 0;
  int audioHapticBuffer = 75;
  Stopwatch timer = Stopwatch();

  SetlistTrack? setlistTrack;

  final PublishSubject<void> _destroySubject = PublishSubject<void>();

  final StreamController<ClickState> _clickStateController =
      StreamController<ClickState>.broadcast();

  Stream<ClickState> get clickStateStream => _clickStateController.stream;

  MetronomeBuzzer buzzer = MetronomeBuzzer();

  Timer? clickTimer;

  bool isClicking = false;

  void adjustAnchorTime(Duration position) {
    anchorTime = timer.elapsed.inMilliseconds - position.inMilliseconds;
  }

  MediaItem? get currentMediaItem {
    return _currentMediaItem;
  }

  set currentMediaItem(MediaItem? value) {
    // Don't try to set this or affect anything if it hasn't changed.
    if (_currentMediaItem?.id == value?.id && value?.id != null) {
      return;
    }

    stopClick();

    _currentMediaItem = value;

    if (value == null) {
      return;
    }

    loadSetlistTrackFromExtras(value.extras);

    _clickStateController.sink.add(ClickState(
        count: ClickInfo.SILENCE_COUNT,
        beatsPerBar:
            setlistTrack!.plTrack?.plTempos?.firstOrNull?.beatsPerBar ?? 4));
  }

  MediaItem? _currentMediaItem;

  void loadSetlistTrackFromExtras(Map<String, dynamic>? extras) {
    setlistTrack = SetlistAudioHandler.decodeExtras(extras);
  }

  ClickInfo? getClickInfo(Tempo tempo, double positionMilliseconds) {
    final double? millisecondsPerBeat =
        TempoRepository.getMillisecondsPerBeat(tempo);

    if (millisecondsPerBeat == null) {
      return null;
    }

    int numBeats = (positionMilliseconds / millisecondsPerBeat).floor();
    final int clickDuration =
        ClickInfo.getClickDurationForBpm(tempo.bpm ?? 60.0);
    final double millisecondsAfterLastClick =
        positionMilliseconds - (numBeats * millisecondsPerBeat);

    if (!TempoRepository.isPositionInRange(tempo, positionMilliseconds)) {
      return null;
    }

    if (positionMilliseconds < 0) {
      // We haven't yet started this tempo.  Click silence until that happens.
      return ClickInfo(
          count: ClickInfo.SILENCE_COUNT,
          tempo: tempo,
          duration: -positionMilliseconds);
    }

    if (millisecondsAfterLastClick <= clickDuration) {
      // we are inside a click.  Indicate the remainder of it, but adjust the click
      // duration for the part that we missed, so it doesn't go too long.
      final int count = numBeats % tempo.beatsPerBar! + 1;
      final double calculatedDuration =
          clickDuration - millisecondsAfterLastClick;

      return ClickInfo(
          count: count, tempo: tempo, duration: calculatedDuration);
    }

    // We are calculating the next click for silence length.
    // First check if the tempo is out of range.
    numBeats++;
    final double beatPosition = numBeats * millisecondsPerBeat,
        positionFromNow = beatPosition - positionMilliseconds;

    if (!TempoRepository.isPositionInRange(tempo, beatPosition)) {
      // Return null, that indicates the position is out of range for this tempo.
      // Tempo iterator will check the next one.
      return null;
    }

    // Return ClickInfo object that indicates we need silence for the positionFromNow duration.
    return ClickInfo(
        count: ClickInfo.SILENCE_COUNT,
        duration: positionFromNow,
        tempo: tempo);
  }

  Future<void> click(ClickInfo clickInfo) async {
    final Completer<void> completer = Completer<void>();

    if (clickInfo.count != ClickInfo.SILENCE_COUNT) {
      buzzer.play(clickInfo.tempo?.bpm?.floor() ?? 60, clickInfo.accent);
    }

    // Do a click.  Sometimes these are silent.
    _clickStateController.sink.add(ClickState(
        count: clickInfo.count,
        accent: clickInfo.accent,
        beatsPerBar: clickInfo.tempo?.beatsPerBar ?? 4));

    clickTimer?.cancel();
    clickTimer = Timer(Duration(milliseconds: clickInfo.duration.ceil()), () {
      completer.complete();
    });
    return completer.future;
  }

  ClickInfo? calculateClick() {
    final int millisecondsFromAnchor =
        timer.elapsedMilliseconds - anchorTime + audioHapticBuffer;

    double position = millisecondsFromAnchor.toDouble();

    for (Tempo tempo in setlistTrack!.plTrack!.plTempos!) {
      final ClickInfo? clickInfo = getClickInfo(tempo, position.toDouble());

      if (clickInfo != null) {
        return clickInfo;
      }

      // Shift position by this tempo's duration, so the next tempo will start at 0.
      position -= TempoRepository.getTempoDurationMilliseconds(tempo) ?? 0;
    }

    // return null.  This will only happen if it is still playing the same track after all tempos are finished.
    return null;
  }

  Future<void> setupNextClick() async {
    // If no setlist track or tempos, exit.
    if (setlistTrack == null ||
        (setlistTrack?.plTrack?.plTempos ?? <Tempo>[]).isEmpty) {
      return;
    }
    final ClickInfo? clickInfo = calculateClick();

    // If the final tempo is not in range, exit without setting up a timeout for click duration.
    // No more clicks.
    if (clickInfo == null || !isClicking) {
      _clickStateController.sink.add(ClickState(
          count: ClickInfo.SILENCE_COUNT,
          beatsPerBar:
              setlistTrack!.plTrack?.plTempos?.firstOrNull?.beatsPerBar ?? 4));

      return;
    }

    // click will update the click state to either clicking or silence.
    await click(clickInfo);

    if (!isClicking) {
      return;
    }

    setupNextClick();
  }

  void stopClick() {
    isClicking = false;
    clickTimer?.cancel();
    clickTimer = null;

    // send a silence to the stream to keep the UI from continuing to be lit.
    // Also set beats per bar to that of the first tempo.
    _clickStateController.sink.add(ClickState(
        count: ClickInfo.SILENCE_COUNT,
        beatsPerBar:
            setlistTrack?.plTrack?.plTempos?.firstOrNull?.beatsPerBar ?? 4));
  }

  void startClick() {
    isClicking = true;
    clickTimer?.cancel();
    setupNextClick();
  }

  void syncState(PlaybackState state) {
    // Get the current queue item.
    final List<MediaItem> queue = _audioHandler.queue.value;
    final MediaItem? mediaItem = state.queueIndex == null
        ? null
        : queue.elementAtOrNull(state.queueIndex!);

    // Keep handle on current media item, and stop our click counters when it changes in a playback.
    // This prevents switching tracks from messing up our click states and causing the timers to never fire.
    currentMediaItem = mediaItem;

    // playing will fire briefly at a 0 position, which is not accurate enough for us to calculate our click anchor time.
    // Wait until it's populated.
    final bool hasPosition = (state.updatePosition.inMicroseconds) > 0;
    if (state.playing && mediaItem != null && hasPosition) {
      if (!isClicking) {
        adjustAnchorTime(state.updatePosition);
        startClick();
      }
    } else {
      stopClick();
    }
  }

  void startListening() {
    _positionSubscription?.cancel();
    _positionSubscription = _audioHandler.positionStream.listen(
      (Duration? position) {
        final PlaybackState playbackState = _audioHandler.playbackState.value;
        final PlaybackState augmentedState = playbackState.copyWith(
            updatePosition: position ?? const Duration(milliseconds: 0));
        syncState(augmentedState);
      },
    );
  }

  void dispose() {
    timer.stop();
    _positionSubscription?.cancel();
    _destroySubject.add(null);
    _destroySubject.close();
  }
}
