import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

// https://suragch.medium.com/background-audio-in-flutter-with-audio-service-and-just-audio-3cce17b4a7d
// ^ Check this for appropriate listeners for the Bloc classes as well.

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => SetlistAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.timwk.inthepocket.audio',
      androidNotificationChannelName: 'In the Pocket Metronome Audio Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class SetlistAudioHandler extends BaseAudioHandler with QueueHandler {
  SetlistAudioHandler() {
    _loadPlaylist();
    _updatePlaybackState();
    _listenForIndexChange();
  }

  void _listenForIndexChange() {
    //
    // Keep current media item synced
    // Use combineLatest2 to make sure the queue updates also trigger this.
    //
    Rx.combineLatest2(_player.sequenceStateStream, queue,
            (SequenceState sequenceStream, List<MediaItem> queue) {
      return sequenceStream;
    })
        .map((SequenceState? s) => s?.currentIndex)
        .distinct()
        .listen((int? index) {
      final List<MediaItem> itemList = queue.value;

      if (index == null || index < 0 || index >= itemList.length) {
        return;
      }

      mediaItem.add(itemList[index]);
    });
  }

  static SetlistTrack? decodeExtras(Map<String, dynamic>? extras) {
    if (extras == null) {
      return null;
    }

    final SetlistTrack currentTrack = SetlistTrack.fromMap(extras);

    final Map<String, dynamic>? trackMap = extras['plTrack'];
    final List<Map<String, dynamic>>? temposMap = extras['plTrack']['plTempos'];

    if (trackMap != null) {
      currentTrack.plTrack = Track.fromMap(trackMap);
    }

    if (temposMap != null) {
      currentTrack.plTrack?.plTempos = temposMap
          .map((Map<String, dynamic> tempoMap) => Tempo.fromMap(tempoMap))
          .toList();
    }

    return currentTrack;
  }

  /// Prepare extras (SetlistTrack) into a map to store in MediaItem extras.
  static Map<String, dynamic> encodeExtras(SetlistTrack setlistTrack) {
    final Map<String, dynamic> extras = setlistTrack.toMap();

    extras['plTrack'] = setlistTrack.plTrack?.toMap();
    extras['plTrack']?['plTempos'] = setlistTrack.plTrack?.plTempos
        ?.map((Tempo tempo) => tempo.toMap())
        .toList();

    return extras;
  }

  final AudioPlayer _player = AudioPlayer();
  final List<UriAudioSource> _audioSources = <UriAudioSource>[];

  Future<void> _loadPlaylist() async {
    try {
      // When called from constructor, playlist is empty, but it doesn't have to be.
      await _player.setAudioSources(_audioSources);
    } catch (e) {
      print('Error: $e');
    }
  }

  void _updatePlaybackState() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final bool playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: <MediaControl>[
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const <MediaAction>{
          MediaAction.seek,
        },
        androidCompactActionIndices: const <int>[0, 1, 3],
        processingState: const <ProcessingState, AudioProcessingState>{
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        repeatMode: const <LoopMode, AudioServiceRepeatMode>{
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // manage Just Audio
    final Iterable<UriAudioSource> audioSource =
        mediaItems.map(_createAudioSource);
    _audioSources.addAll(audioSource.toList());
    await _player.setAudioSources(_audioSources);

    // notify system
    final List<MediaItem> newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // manage Just Audio
    final UriAudioSource audioSource = _createAudioSource(mediaItem);
    _audioSources.add(audioSource);
    await _player.setAudioSources(_audioSources);

    // notify system
    final List<MediaItem> newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.file(mediaItem.id),
      tag: mediaItem,
    );
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    // manage Just Audio
    _audioSources.removeAt(index);
    await _player.setAudioSources(_audioSources);

    // notify system
    final List<MediaItem> newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() async {
    await _player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await _player.seekToPrevious();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      _player.setShuffleModeEnabled(false);
    } else {
      await _player.shuffle();
      _player.setShuffleModeEnabled(true);
    }
  }

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    if (button == MediaButton.media &&
        playbackState.valueOrNull?.playing == true) {
      await stop();
      await seek(const Duration(milliseconds: 0));
    } else {
      return super.click(button);
    }
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'clear') {
      _audioSources.clear();
      queue.add(<MediaItem>[]);
      await _loadPlaylist();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }
}
