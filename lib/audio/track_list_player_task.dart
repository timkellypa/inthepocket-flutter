import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';
import 'package:just_audio/just_audio.dart';

class TrackListPlayerTask extends BackgroundAudioTask {
  TrackListPlayerTask();

  // final List<SetListTrackProxy> setListTracks;
  // final SetListProxy setList;
  final TempoRepository tempoRepository = TempoRepository();
  final List<MediaItem> _queue = <MediaItem>[];

  /*
  Future<void> initializeQueue() async {
    _queue = <MediaItem>[];

    for (SetListTrackProxy setListTrack in setListTracks) {
      _queue.add(
        MediaItem(
          id: 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
          // id: await tempoRepository.getClickTrackPath(setListTrack.trackId),
          album: setList.description,
          title: setListTrack.track.title,
        ),
      );
    }
  }
  */

  MediaControl playControl = const MediaControl(
    androidIcon: 'drawable/ic_action_play_arrow',
    label: 'Play',
    action: MediaAction.play,
  );
  MediaControl pauseControl = const MediaControl(
    androidIcon: 'drawable/ic_action_pause',
    label: 'Pause',
    action: MediaAction.pause,
  );
  MediaControl skipToNextControl = const MediaControl(
    androidIcon: 'drawable/ic_action_skip_next',
    label: 'Next',
    action: MediaAction.skipToNext,
  );
  MediaControl skipToPreviousControl = const MediaControl(
    androidIcon: 'drawable/ic_action_skip_previous',
    label: 'Previous',
    action: MediaAction.skipToPrevious,
  );
  MediaControl stopControl = const MediaControl(
    androidIcon: 'drawable/ic_action_stop',
    label: 'Stop',
    action: MediaAction.stop,
  );

  int _queueIndex = -1;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Completer<dynamic> _completer = Completer<dynamic>();
  BasicPlaybackState _skipState;
  bool _playing = false;

  bool get hasNext => _queueIndex + 1 < _queue.length;

  bool get hasPrevious => _queueIndex > 0;

  MediaItem get mediaItem => _queue.isNotEmpty ? _queue[_queueIndex] : null;

  Future<List<MediaItem>> getQueue() async {
    // wait until we have contents
    await Future.doWhile(() {
      return _queue.isEmpty;
    });
    return _queue;
  }

  BasicPlaybackState _stateToBasicState(AudioPlaybackState state) {
    switch (state) {
      case AudioPlaybackState.none:
        return BasicPlaybackState.none;
      case AudioPlaybackState.stopped:
        return BasicPlaybackState.stopped;
      case AudioPlaybackState.paused:
        return BasicPlaybackState.paused;
      case AudioPlaybackState.playing:
        return BasicPlaybackState.playing;
      case AudioPlaybackState.buffering:
        return BasicPlaybackState.buffering;
      case AudioPlaybackState.connecting:
        return _skipState ?? BasicPlaybackState.connecting;
      case AudioPlaybackState.completed:
        return BasicPlaybackState.stopped;
      default:
        throw Exception('Illegal state');
    }
  }

  @override
  Future<void> onStart() async {
    final StreamSubscription<AudioPlaybackState> playerStateSubscription =
        _audioPlayer.playbackStateStream
            .where((AudioPlaybackState state) =>
                state == AudioPlaybackState.completed)
            .listen((AudioPlaybackState state) {
      _handlePlaybackCompleted();
    });
    final StreamSubscription<AudioPlaybackEvent> eventSubscription =
        _audioPlayer.playbackEventStream.listen((AudioPlaybackEvent event) {
      final BasicPlaybackState state = _stateToBasicState(event.state);
      if (state != BasicPlaybackState.stopped) {
        _setState(
          state: state,
          position: event.position.inMilliseconds,
        );
      }
    });

    // AudioServiceBackground.setQueue(await getQueue());

    // await onSkipToNext();
    await _completer.future;
    playerStateSubscription.cancel();
    eventSubscription.cancel();
  }

  void _handlePlaybackCompleted() {
    if (hasNext) {
      onSkipToNext();
    } else {
      onStop();
    }
  }

  void playPause() {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      onPause();
    else
      onPlay();
  }

  @override
  void onAddQueueItem(MediaItem mediaItem) {
    super.onAddQueueItem(mediaItem);

    _queue.add(mediaItem);
  }

  @override
  Future<void> onSkipToNext() => _skip(1);

  @override
  void onPlayFromMediaId(String mediaId) {
    super.onPlayFromMediaId(mediaId);
    _playItem(mediaId);
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    await _setIndex(mediaId);
    await _prepareCurrentItem();
  }

  @override
  Future<void> onCustomAction(String name, dynamic arguments) async {
    if (name == 'resetQueue') {
      _queue.clear();
    }
  }

  /// Stop playback if we are playing
  Future<void> _stopPlayback() async {
    if (_playing) {
      // Stop current item
      await _audioPlayer.stop();
    }
  }

  Future<void> _setIndex(String mediaId) async {
    await _stopPlayback();
    for (int i = 0; i < _queue.length; ++i) {
      if (_queue[i].id == mediaId) {
        _queueIndex = i;
        break;
      }
    }
  }

  Future<void> _playItem(String mediaId) async {
    _setIndex(mediaId);
    _playing = true;
    await _prepareCurrentItem();
  }

  Future<void> _prepareCurrentItem() async {
    if (mediaItem == null) {
      return;
    }
    AudioServiceBackground.setMediaItem(mediaItem);
    await _audioPlayer.setUrl(mediaItem.id);
    _skipState = null;
    // Resume playback if we were playing
    if (_playing) {
      onPlay();
    } else {
      _setState(state: BasicPlaybackState.paused);
    }
  }

  @override
  Future<void> onSkipToPrevious() => _skip(-1);

  Future<void> _skip(int offset) async {
    final int newPos = _queueIndex + offset;
    if (!(newPos >= 0 && newPos < _queue.length)) {
      return;
    }

    await _stopPlayback();

    _skipState = offset > 0
        ? BasicPlaybackState.skippingToNext
        : BasicPlaybackState.skippingToPrevious;

    // Load next item
    _queueIndex = newPos;
    await _prepareCurrentItem();
  }

  @override
  Future<void> onPrepare() async {
    super.onPrepare();
    await AudioServiceBackground.setQueue(_queue);

    // make all invalid queue indexes go to first option
    if (_queueIndex > _queue.length) {
      _queueIndex = -1;
    }
    if (_queueIndex == -1) {
      await onSkipToNext();
    } else {
      _prepareCurrentItem();
    }
  }

  @override
  void onPlay() {
    if (_skipState == null) {
      _playing = true;
      _audioPlayer.play();
    }
  }

  @override
  void onPause() {
    if (_skipState == null) {
      _playing = false;
      _audioPlayer.pause();
    }
  }

  @override
  void onSeekTo(int position) {
    _audioPlayer.seek(Duration(milliseconds: position));
  }

  @override
  void onClick(MediaButton button) {
    playPause();
  }

  @override
  void onStop() {
    switch (AudioServiceBackground.state.basicState) {
      case BasicPlaybackState.paused:
      case BasicPlaybackState.playing:
        _audioPlayer.stop();
        _setState(state: BasicPlaybackState.stopped);
        break;
      default:
    }
    _completer.complete();
  }

  void _setState({@required BasicPlaybackState state, int position}) {
    position ??= _audioPlayer.playbackEvent.position.inMilliseconds;
    AudioServiceBackground.setState(
      controls: getControls(state),
      systemActions: <MediaAction>[MediaAction.seekTo],
      basicState: state,
      position: position,
    );
  }

  List<MediaControl> getControls(BasicPlaybackState state) {
    if (_playing) {
      return <MediaControl>[
        skipToPreviousControl,
        pauseControl,
        skipToNextControl
      ];
    } else {
      return <MediaControl>[
        skipToPreviousControl,
        playControl,
        skipToNextControl
      ];
    }
  }
}
