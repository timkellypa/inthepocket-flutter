import 'dart:async';
import 'dart:collection';
import 'package:audio_service/audio_service.dart';
import 'package:in_the_pocket/audio/track_list_player_task.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';
import 'package:in_the_pocket/models/independent/track.g.m8.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';
import 'package:in_the_pocket/repository/track_repository.dart';

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

class TrackBloc extends ModelBlocBase<SetListTrackProxy, TrackRepository> {
  TrackBloc(this.setList, {this.importTargetSetList}) : super();

  final SetListProxy setList;

  final SetListProxy importTargetSetList;

  bool firstFetch = true;

  Function get importExclusionsFilter {
    return (SetListTrackProxy proxy) =>
        proxy.setListId == importTargetSetList.id;
  }

  @override
  TrackRepository get repository {
    return TrackRepository();
  }

  @override
  Function get listFilter {
    return (SetListTrackProxy proxy) =>
        proxy.setListId == (setList?.id ?? proxy.setListId);
  }

  @override
  String get listTitle {
    return setList.description;
  }

  @override
  Future<List<SetListTrackProxy>> fetch() async {
    final List<SetListTrackProxy> setListTracks = await getItemList();

    for (SetListTrackProxy setListTrack in setListTracks) {
      setListTrack.track = await repository.getTrackById(setListTrack.trackId);
    }

    if (importTargetSetList != null && firstFetch) {
      firstFetch = false;
      final List<SetListTrackProxy> existingTracks =
          await getItemList(filter: importExclusionsFilter, update: false);

      // create reverse lookup for existing tracks
      final HashMap<String, SetListTrackProxy> existingTrackMap =
          HashMap<String, SetListTrackProxy>.fromEntries(existingTracks.map(
              (SetListTrackProxy track) => MapEntry<String, SetListTrackProxy>(
                  track.trackId.toString(), track)));

      for (SetListTrackProxy setListTrack in setListTracks) {
        if (existingTrackMap.containsKey(setListTrack.trackId.toString())) {
          selectItem(setListTrack, SelectionType.disabled, doSync: false);
        }
      }

      syncSelections();
    }

    listController.sink.add(setListTracks);
    return setListTracks;
  }

  @override
  Future<void> insert(SetListTrackProxy item) async {
    await repository.insert(item);
    fetch();
  }

  @override
  Future<void> update(SetListTrackProxy item) async {
    await repository.update(item);
    fetch();
  }

  @override
  Future<void> delete(SetListTrackProxy item) async {
    await repository.delete(item.id);
    fetch();
  }

  Future<void> applySpotifyAudioFeatures(
      List<SetListTrackProxy> setListTracks) async {
    final List<TrackProxy> tracks = setListTracks
        .map((SetListTrackProxy setListTrack) => setListTrack.track);
    await repository.applySpotifyAudioFeatures(tracks);
    fetch();
  }

  void changeTrack(TrackDirection direction) {
    final List<SetListTrackProxy> selectedSetListTracks =
        getMatchingSelections(SelectionType.selected);
    final SetListTrackProxy selectedSetListTrack =
        selectedSetListTracks.isNotEmpty ? selectedSetListTracks.first : null;
    int targetIndex;
    if (selectedSetListTrack == null) {
      targetIndex = direction == TrackDirection.next ? 0 : itemList.length - 1;
    } else {
      targetIndex = itemList.indexOf(selectedSetListTrack) +
          (direction == TrackDirection.next ? 1 : -1);
      if (targetIndex >= 0 && targetIndex < itemList.length) {
        unSelectAll(SelectionType.selected, doSync: false);
        selectItem(itemList[targetIndex], SelectionType.selected);
      }
    }
  }

  void connectAudio() {
    AudioService.connect();
  }

  Future<void> startAudioService() async {
    AudioService.start(
      backgroundTaskEntrypoint: _trackListPlayerTaskEntrypoint,
      resumeOnClick: true,
      notificationColor: 0xFF2196f3,
      enableQueue: true,
      androidNotificationChannelName: CHANNEL_NAME,
      androidNotificationIcon: NOTIFICATION_ICON,
    );

    for (SetListTrackProxy setListTrack in itemList) {
      AudioService.addQueueItem(
        MediaItem(
          id: await TempoRepository().getClickTrackPath(setListTrack.trackId),
          album: setList.description,
          title: setListTrack.track.title,
          artist: setList.location,
          duration: 2856950,
        ),
      );
    }
  }

  void stop() {
    AudioService.stop();
  }

  void play() {
    AudioService.play();
  }

  void skipToNext() {
    AudioService.skipToNext();
  }

  void skipToPrevious() {
    AudioService.skipToPrevious();
  }

  void skipToQueueItem(String trackPath) {
    AudioService.skipToQueueItem(trackPath);
  }
}

void _trackListPlayerTaskEntrypoint() {
  AudioServiceBackground.run(() => TrackListPlayerTask());
}
