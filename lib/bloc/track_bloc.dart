import 'dart:async';
import 'dart:collection';
import 'package:audio_service/audio_service.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';
import 'package:in_the_pocket/repository/track_repository.dart';
import 'package:in_the_pocket/services/service_locator.dart';

import 'model_bloc_base.dart';

enum TrackDirection { next, previous }

const String CHANNEL_NAME = 'Metronome';
const String NOTIFICATION_ICON = 'mipmap/ic_launcher';

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

class TrackBloc extends ModelBlocBase<SetlistTrack, TrackRepository> {
  TrackBloc(this.setlist, {this.importTargetSetlist}) : super();

  final Setlist? setlist;

  final Setlist? importTargetSetlist;

  final AudioHandler _audioHandler = getIt<AudioHandler>();

  bool firstFetch = true;

  /// Forward AudioService playback state
  Stream<PlaybackState> get audioPlaybackStream {
    return _audioHandler.playbackState;
  }

  PlaybackState get audioPlaybackState {
    return _audioHandler.playbackState.value;
  }

  bool Function(SetlistTrack) get importExclusionsFilter {
    return (SetlistTrack track) =>
        track.setlistId == importTargetSetlist?.id;
  }

  @override
  TrackRepository get repository {
    return TrackRepository();
  }

  @override
  bool Function(SetlistTrack) get listFilter {
    return (SetlistTrack track) =>
        track.setlistId == setlist?.id;
  }

  @override
  String get listTitle {
    return setlist?.description ?? '';
  }

  SetlistTrack? get selectedSetlistTrack {
    final List<SetlistTrack?> selectedSetlistTracks =
        getMatchingSelections(SelectionType.selected);
    return selectedSetlistTracks.isNotEmpty
        ? selectedSetlistTracks.first
        : null;
  }

  @override
  Future<List<SetlistTrack>> fetch() async {
    final List<SetlistTrack> setlistTracks = await getItemList();

    if (firstFetch) {
      firstFetch = false;
      final List<SetlistTrack> existingTracks =
          await getItemList(filter: importExclusionsFilter, update: false);

      // create reverse lookup for existing tracks
      final HashMap<String, SetlistTrack> existingTrackMap =
          HashMap<String, SetlistTrack>.fromEntries(existingTracks.map(
              (SetlistTrack track) => MapEntry<String, SetlistTrack>(
                  track.trackId.toString(), track)));

      for (SetlistTrack setlistTrack in setlistTracks) {
        if (existingTrackMap.containsKey(setlistTrack.trackId.toString())) {
          selectItem(setlistTrack, SelectionType.disabled, doSync: false);
        }
      }

      syncSelections();
    }

    await loadMediaItems();

    listController.sink.add(setlistTracks);
    return setlistTracks;
  }

  @override
  Future<void> insert(SetlistTrack item) async {
    await repository.insert(item);
    fetch();
  }

  @override
  Future<void> update(SetlistTrack item) async {
    await repository.update(item);
    fetch();
  }

  @override
  Future<void> delete(SetlistTrack item) async {
    await repository.delete(item.id!);
    fetch();
  }

  Future<void> applySpotifyAudioFeatures(
      List<SetlistTrack> setlistTracks) async {
    final List<Track> tracks = setlistTracks
        .map((SetlistTrack setlistTrack) => setlistTrack.plTrack) as List<Track>;
    await repository.applySpotifyAudioFeatures(tracks, notify: (int total, double progress) {
      
    },);
    fetch();
  }

  void changeTrack(TrackDirection direction) {
    int targetIndex;
    if (selectedSetlistTrack == null) {
      targetIndex = direction == TrackDirection.next ? 0 : itemList.length - 1;
    } else {
      targetIndex = itemList.indexOf(selectedSetlistTrack!) +
          (direction == TrackDirection.next ? 1 : -1);
      if (targetIndex >= 0 && targetIndex < itemList.length) {
        unSelectAll(SelectionType.selected, doSync: false);
        selectItem(itemList[targetIndex], SelectionType.selected);
      }
    }
  }

  void mediaItemChanged(MediaItem mediaItem) {
    final String trackId = TempoRepository().getTrackIdFromPath(mediaItem.id);
    // find media item in list
    final SetlistTrack selectedSetlistTrack = itemList
        .where(
            (SetlistTrack setlistTrack) => setlistTrack.trackId == trackId)
        .first;
    selectItem(selectedSetlistTrack, SelectionType.selected,
        pushToAudioService: false);
  }

  @override
  Future<void> selectItem(SetlistTrack? model, int selectionTypes,
      {bool doSync = true, bool pushToAudioService = true}) async {

    // do nothing if selection is already done
    if (itemSelectionMap.containsKey(model?.id) &&
        itemSelectionMap[model?.id]!.selectionType & selectionTypes > 0) {
      return;
    }

    if (selectionTypes & SelectionType.selected > 0) {
      unSelectAll(SelectionType.selected);
    }
    super.selectItem(model, selectionTypes, doSync: doSync);
    if (pushToAudioService && selectionTypes & SelectionType.selected > 0 && model != null) {
        final int index = itemList.indexOf(model);
        _audioHandler.skipToQueueItem(index);
    }
  }

  Future<void> loadMediaItems() async {
    await _audioHandler.customAction('resetQueue');

    for (SetlistTrack setlistTrack in itemList) {
      await _audioHandler.addQueueItem(MediaItem(
        id: await TempoRepository().getClickTrackPath(setlistTrack.trackId!),
        album: setlist?.description ?? '',
        title: setlistTrack.plTrack?.title ?? '',
        artist: setlist?.location ?? ''
      ));
    }
    await _audioHandler.prepare();
  }

  void stop() {
    _audioHandler.stop();
  }

  Future<void> audioClick() async {
    await _audioHandler.click();
  }

  void skipToNext() {
    _audioHandler.skipToNext();
  }

  void skipToPrevious() {
    _audioHandler.skipToPrevious();
  }

  @override
  void dispose() {
    _audioHandler.stop();
  }
}
