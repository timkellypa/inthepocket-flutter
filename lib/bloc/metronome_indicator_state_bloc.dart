import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:in_the_pocket/audio/setlist_audio_handler.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';
import 'package:in_the_pocket/services/service_locator.dart';

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

  static int getClickDurationForTempo(Tempo? tempo) {
    if (tempo == null || tempo.bpm == null) {
      return 100;
    }
    return min(100, (60 / tempo.bpm! * 1000 - 10).round());
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

class MetronomeIndicatorStateBloc {
  MetronomeIndicatorStateBloc() {
    _clickStateController.sink.add(ClickState(count: 0));
    startListening();
  }

  final AudioHandler _audioHandler = getIt<AudioHandler>();

  DateTime anchorTime = DateTime.now();

  SetlistTrack? setlistTrack;

  StreamSubscription<PlaybackState>? stateSubscription;
  StreamSubscription<MediaItem?>? mediaItemSubscription;

  final StreamController<ClickState> _clickStateController =
      StreamController<ClickState>.broadcast();

  Stream<ClickState> get clickStateStream => _clickStateController.stream;

  Timer? clickTimer;

  bool isClicking = false;

  void adjustAnchorTime(Duration position) {
    anchorTime = DateTime.now().subtract(position);
  }

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
    final int clickDurationForTempo = ClickInfo.getClickDurationForTempo(tempo);
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

    if (millisecondsAfterLastClick <= clickDurationForTempo) {
      // we are inside a click.  Indicate the remainder of it, but adjust the click
      // duration for the part that we missed, so it doesn't go too long.
      final int count = numBeats % tempo.beatsPerBar! + 1;
      final double clickDuration =
          clickDurationForTempo - millisecondsAfterLastClick;

      return ClickInfo(count: count, tempo: tempo, duration: clickDuration);
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
    final int millisecondsFromAnchor = DateTime.now().millisecondsSinceEpoch -
        anchorTime.millisecondsSinceEpoch;

    // Add a millisecond if this is during the click.  This makes sure our calculation
    // is for the next one, not the current one.
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
  }

  void startClick() {
    isClicking = true;
    clickTimer?.cancel();
    setupNextClick();
  }

  void syncState(PlaybackState state) {
    if (state.playing) {
      adjustAnchorTime(state.position);
      if (!isClicking) {
        startClick();
      }
    } else {
      stopClick();
    }
  }

  void setNoMediaItemState() {
    stateSubscription?.cancel();
    setlistTrack = null;
    anchorTime = DateTime.now();
    stopClick();

    _clickStateController.sink
        .add(ClickState(count: ClickInfo.SILENCE_COUNT, beatsPerBar: 0));
  }

  void setupStateListener(MediaItem? mediaItem) {
    if (mediaItem == null) {
      setNoMediaItemState();
      return;
    }

    stateSubscription?.cancel();
    stateSubscription = _audioHandler.playbackState
        .listen((PlaybackState playbackState) => syncState(playbackState));
  }

  void setCurrentMediaItem(MediaItem? mediaItem) {
    stopClick();

    setupStateListener(mediaItem);

    if (mediaItem == null) {
      return;
    }

    loadSetlistTrackFromExtras(mediaItem.extras);

    _clickStateController.sink.add(ClickState(
        count: ClickInfo.SILENCE_COUNT,
        beatsPerBar:
            setlistTrack!.plTrack?.plTempos?.firstOrNull?.beatsPerBar ?? 4));
  }

  void startListening() {
    mediaItemSubscription?.cancel();
    mediaItemSubscription = _audioHandler.mediaItem
        .listen((MediaItem? mediaItem) => setCurrentMediaItem(mediaItem));
  }

  void stopListening() {
    mediaItemSubscription?.cancel();
    stateSubscription?.cancel();
  }

  void dispose() {
    stopListening();
  }
}
