import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:just_audio/just_audio.dart';

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
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
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
  final ConcatenatingAudioSource _playlist =
      ConcatenatingAudioSource(children: <AudioSource>[]);

  Future<void> _loadPlaylist() async {
    try {
      // When called from constructor, playlist is empty, but it doesn't have to be.
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print('Error: $e');
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
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

  void _listenForDurationChanges() {
    _player.durationStream.listen((Duration? duration) {
      int? index = _player.currentIndex;
      final List<MediaItem> newQueue = queue.value;
      if (index == null || newQueue.isEmpty) {
        return;
      }
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices!.indexOf(index);
      }
      final MediaItem oldMediaItem = newQueue[index];
      final MediaItem newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((int? index) {
      final List<MediaItem> playlist = queue.value;
      if (index == null || playlist.isEmpty) {
        return;
      }
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices!.indexOf(index);
      }
      mediaItem.add(playlist[index]);
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final List<IndexedAudioSource>? sequence =
          sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) {
        return;
      }
      final Iterable<MediaItem> items =
          sequence.map((IndexedAudioSource source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // manage Just Audio
    final Iterable<UriAudioSource> audioSource =
        mediaItems.map(_createAudioSource);
    _playlist.addAll(audioSource.toList());

    // notify system
    final List<MediaItem> newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // manage Just Audio
    final UriAudioSource audioSource = _createAudioSource(mediaItem);
    _playlist.add(audioSource);

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
    _playlist.removeAt(index);

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
    if (index < 0 || index >= queue.value.length) {
      return;
    }
    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices![index];
    }
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
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'clear') {
      _playlist.clear();
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
