import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:in_the_pocket/audio/setlist_audio_handler.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';
import 'package:in_the_pocket/services/service_locator.dart';

class ClickInfo {
  ClickInfo(
      {required this.positionFromNow,
      required this.count,
      this.tempo,
      int? duration}) {
    _duration = duration;
  }

  double positionFromNow;

  bool get isInRange {
    return count != 0;
  }

  bool get accent {
    if (tempo == null) {
      return false;
    }
    return TempoRepository.isCountPrimary(tempo!, count);
  }

  int get duration {
    return _duration ?? getClickDurationForTempo(tempo);
  }

  /// Note, count of 0 means we are out of range.
  int count;
  Tempo? tempo;
  int? _duration;

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
    return count != 0;
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

  Timer? nextClickTimer;

  void adjustAnchorTime(Duration position) {
    anchorTime = DateTime.now().subtract(position);
  }

  void loadSetlistTrackFromExtras(Map<String, dynamic>? extras) {
    setlistTrack = SetlistAudioHandler.decodeExtras(extras);
  }

  double? getTempoDurationMilliseconds(Tempo tempo) {
    if (tempo.numberOfBars == null || tempo.numberOfBars == 0) {
      return null;
    }
    return tempo.numberOfBars! * tempo.beatsPerBar! / tempo.bpm! * 60 * 1000;
  }

  ClickInfo getNextClickInfo(Tempo tempo, double positionMilliseconds) {
    final double? tempoDurationMilliseconds =
        getTempoDurationMilliseconds(tempo);

    final double perCountMilliseconds = 60 / tempo.bpm! * 1000;

    // count is 1 indexed, and 0th position of file is first count
    int numBeats = (positionMilliseconds / perCountMilliseconds).floor();
    final int clickDurationForTempo = ClickInfo.getClickDurationForTempo(tempo);
    final int millisecondsAfterLastClick =
        positionMilliseconds.round() % perCountMilliseconds.round();
    if (millisecondsAfterLastClick < clickDurationForTempo) {
      // we are inside a click.  Indicate the remainder of it, but adjust the click
      // duration for the part that we missed, so it doesn't go too long.
      const double positionFromNow = 0;
      final int count = numBeats % tempo.beatsPerBar! + 1;
      final int clickDuration =
          clickDurationForTempo - millisecondsAfterLastClick;

      return ClickInfo(
          count: count,
          positionFromNow: positionFromNow,
          tempo: tempo,
          duration: clickDuration);
    }

    // We are calculating the next click.
    numBeats++;

    final double beatPosition = numBeats * perCountMilliseconds,
        positionFromNow = beatPosition - positionMilliseconds;

    if (tempoDurationMilliseconds != null &&
        tempoDurationMilliseconds.round() <= beatPosition.round()) {
      // Return special ClickInfo object, that indicates the position is out of range (count=0)
      // and returns duration of tempo in "position" attribute.
      return ClickInfo(
          count: 0, positionFromNow: tempoDurationMilliseconds, tempo: tempo);
    }

    final int count = numBeats % tempo.beatsPerBar! + 1;

    return ClickInfo(
        count: count, positionFromNow: positionFromNow, tempo: tempo);
  }

  Future<void> click(ClickInfo clickInfo) async {
    final Completer<void> completer = Completer<void>();

    _clickStateController.sink.add(ClickState(
        count: clickInfo.count,
        accent: clickInfo.accent,
        beatsPerBar: clickInfo.tempo?.beatsPerBar ?? 4));

    Timer(Duration(milliseconds: clickInfo.duration), () {
      _clickStateController.sink.add(
          ClickState(count: 0, beatsPerBar: clickInfo.tempo?.beatsPerBar ?? 4));
      completer.complete();
    });
    return completer.future;
  }

  ClickInfo calculateNextClick() {
    final int millisecondsFromAnchor = DateTime.now().millisecondsSinceEpoch -
        anchorTime.millisecondsSinceEpoch;

    // Add a millisecond if this is during the click.  This makes sure our calculation
    // is for the next one, not the current one.
    double position = millisecondsFromAnchor.toDouble();

    for (Tempo tempo in setlistTrack!.plTrack!.plTempos!) {
      final ClickInfo clickInfo = getNextClickInfo(tempo, position);

      if (clickInfo.isInRange) {
        return clickInfo;
      }

      // Shift position by this click's duration offset.
      position -= clickInfo.positionFromNow;
    }

    // return out of range clickinfo.  This should not happen.
    return ClickInfo(count: 0, positionFromNow: position, tempo: null);
  }

  void setupNextClick() {
    // If no setlist track or tempos, exit.
    if (setlistTrack == null ||
        (setlistTrack?.plTrack?.plTempos ?? <Tempo>[]).isEmpty) {
      return;
    }
    final ClickInfo clickInfo = calculateNextClick();

    // If the final tempo is not in range, exit without setting up a timeout for click duration.
    // No more clicks.
    if (!clickInfo.isInRange) {
      return;
    }

    nextClickTimer = Timer(
        Duration(milliseconds: clickInfo.positionFromNow.round()), () async {
      /**
       * Inactive timer will still get here, so stop it (like canceling an interval)
       * We don't use an interval for two reasons.
       * 1. We have an anchor time equaling the playback start time to be as accurate as possible.
       * 2. Tempos can change within a single mediaItem.  This calculation is done with setupNextClick().
       */
      if (nextClickTimer != null) {
        await click(clickInfo);

        // Could have become null during the click.
        if (nextClickTimer != null) {
          setupNextClick();
        }
      }
    });
  }

  void stopClick() {
    nextClickTimer?.cancel();
    nextClickTimer = null;
  }

  void syncState(PlaybackState state) {
    if (state.playing) {
      adjustAnchorTime(state.position);
      if (nextClickTimer == null) {
        setupNextClick();
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
