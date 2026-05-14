import 'dart:async';
import 'dart:collection';
import 'package:audio_service/audio_service.dart';
import 'package:in_the_pocket/audio/setlist_audio_handler.dart';
import 'package:in_the_pocket/bloc/metronome_indicator_state_bloc.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/classes/setlist_progress.dart';
import 'package:in_the_pocket/classes/time_range.dart';
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
  TrackBloc(this.setlist, {this.importTargetSetlist, this.preloadTempos = true})
      : super() {
    audioQueueItemListener = audioQueueItemState.listen(mediaItemChanged);
  }

  late StreamSubscription<MediaItem?> audioQueueItemListener;

  SetlistProgress setlistProgress = SetlistProgress();

  final Setlist? setlist;

  final Setlist? importTargetSetlist;

  final bool preloadTempos;

  final AudioHandler _audioHandler = getIt<AudioHandler>();

  final MetronomeIndicatorStateBloc indicatorStateBloc =
      MetronomeIndicatorStateBloc();

  final StreamController<SetlistProgress> setlistProgressController =
      StreamController<SetlistProgress>.broadcast();

  Stream<SetlistProgress> get setlistProgressStream =>
      setlistProgressController.stream;

  /// Forward AudioService playback state
  Stream<PlaybackState> get audioPlaybackStream {
    return _audioHandler.playbackState;
  }

  Stream<MediaItem?> get audioQueueItemState {
    return _audioHandler.mediaItem;
  }

  PlaybackState get audioPlaybackState {
    return _audioHandler.playbackState.value;
  }

  Timer? setlistProgressTimer;

  bool Function(SetlistTrack) get importExclusionsFilter {
    return (SetlistTrack track) => track.setlistId == importTargetSetlist?.id;
  }

  @override
  TrackRepository get repository {
    return TrackRepository();
  }

  @override
  bool Function(SetlistTrack) get listFilter {
    return (SetlistTrack track) => track.setlistId == setlist?.id;
  }

  @override
  String get listTitle {
    return setlist?.description ?? '';
  }

  bool get isFirstSelected {
    return isSelected(itemList.firstOrNull, SelectionType.selected);
  }

  bool get isLastSelected {
    return isSelected(itemList.lastOrNull, SelectionType.selected);
  }

  SetlistTrack? get selectedSetlistTrack {
    final List<SetlistTrack?> selectedSetlistTracks =
        getMatchingSelections(SelectionType.selected);
    return selectedSetlistTracks.isNotEmpty
        ? selectedSetlistTracks.first
        : null;
  }

  /// Load all tempos in bulk from db, and put into appropriate track list.
  /// Should be faster than querying the list individually per track
  Future<void> loadTempos(List<SetlistTrack> setlistTracks) async {
    // create reverse lookup for set list tracks based on track ID.
    final HashMap<String, SetlistTrack> trackMap =
        HashMap<String, SetlistTrack>.fromEntries(setlistTracks.map(
            (SetlistTrack setlistTrack) => MapEntry<String, SetlistTrack>(
                setlistTrack.trackId.toString(), setlistTrack)));

    final List<String> setlistTrackIds = setlistTracks
        .map((SetlistTrack setlistTrack) => setlistTrack.plTrack?.id ?? '')
        .toList();

    final List<Tempo> tempos = await Tempo()
        .select()
        .trackId
        .inValues(setlistTrackIds)
        .orderBy('row__sortOrder')
        .toList();

    for (Tempo tempo in tempos) {
      final SetlistTrack? track = trackMap[tempo.trackId];
      if (track == null) {
        continue;
      }

      track.plTrack?.plTempos ??= List<Tempo>.empty(growable: true);
      track.plTrack?.plTempos?.add(tempo);
    }
  }

  @override
  Future<List<SetlistTrack>> fetch() async {
    final List<SetlistTrack> setlistTracks = await getItemList();

    final List<SetlistTrack> existingTracks =
        await getItemList(filter: importExclusionsFilter);

    // create reverse lookup for existing tracks
    final HashMap<String, SetlistTrack> existingTrackMap =
        HashMap<String, SetlistTrack>.fromEntries(existingTracks.map(
            (SetlistTrack track) => MapEntry<String, SetlistTrack>(
                track.trackId.toString(), track)));

    for (SetlistTrack setlistTrack in setlistTracks) {
      if (existingTrackMap.containsKey(setlistTrack.trackId.toString())) {
        selectItem(setlistTrack, SelectionType.disabled,
            doSync: false, allowMultiSelect: true, allowSelectionToggle: false);
      }
    }

    if (preloadTempos) {
      await loadTempos(setlistTracks);
    }

    syncSelections();
    await syncList(setlistTracks);

    syncSetlistProgress();

    return setlistTracks;
  }

  @override
  Future<void> syncList(List<SetlistTrack> newItemList) async {
    super.syncList(newItemList);

    // Don't load up media if we are importing.
    if (importTargetSetlist == null) {
      loadMediaItems(newItemList);
    }
  }

  @override
  Future<void> insert(SetlistTrack item) async {
    await repository.insert(item);
  }

  @override
  Future<void> update(SetlistTrack item) async {
    await repository.update(item);
  }

  @override
  Future<void> delete(SetlistTrack item) async {
    await repository.delete(item.id!);
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

  void mediaItemChanged(MediaItem? mediaItem) {
    final SetlistTrack? currentTrack =
        SetlistAudioHandler.decodeExtras(mediaItem?.extras);

    // if no track or is already selected, return without doing anything.
    if (currentTrack == null ||
        isSelected(currentTrack, SelectionType.selected)) {
      return;
    }

    selectItem(currentTrack, SelectionType.selected,
        doSync: true, pushToAudioService: false);
  }

  void syncSetlistProgress() {
    bool foundCurrent = false;
    int index = 0;
    int totalDuration = 0;
    int pendingDuration = 0;
    int currentTrackIndex = 0;
    int currentTrackDuration = 0;
    bool remainingTracksWithoutDurationExist = false;

    for (SetlistTrack track in itemList) {
      final int trackDuration = track.plTrack?.duration ?? 0;
      totalDuration += trackDuration;
      if (isSelected(track, SelectionType.selected)) {
        foundCurrent = true;
        currentTrackIndex = index;
        currentTrackDuration = trackDuration;
      }

      if (foundCurrent) {
        pendingDuration += trackDuration;
        if (trackDuration == 0) {
          remainingTracksWithoutDurationExist = true;
        }
      }

      index++;
    }

    setlistProgress.totalDuration = totalDuration;
    setlistProgress.remainingDuration =
        foundCurrent ? pendingDuration : totalDuration;
    setlistProgress.currentTrackIndex = currentTrackIndex;
    setlistProgress.remainingTracksWithoutDurationExist =
        remainingTracksWithoutDurationExist;
    setlistProgress.totalTracks = index;
    setlistProgress.currentTrackDuration = currentTrackDuration;
    setlistProgressController.sink.add(setlistProgress);
  }

  @override
  Future<void> selectItem(SetlistTrack? model, int selectionTypes,
      {bool doSync = true,
      bool pushToAudioService = true,
      bool allowMultiSelect = false,
      bool allowSelectionToggle = true}) async {
    super.selectItem(model, selectionTypes,
        doSync: doSync,
        allowMultiSelect: allowMultiSelect,
        allowSelectionToggle: allowSelectionToggle);

    if (pushToAudioService &&
        selectionTypes & SelectionType.selected > 0 &&
        model != null) {
      final int index = itemList.indexOf(model);
      _audioHandler.skipToQueueItem(index);
    }

    syncSetlistProgress();
  }

  Future<void> loadMediaItems(List<SetlistTrack> setlistTracks) async {
    await _audioHandler.customAction('clear');

    for (SetlistTrack setlistTrack in setlistTracks) {
      final Map<String, dynamic> extras =
          SetlistAudioHandler.encodeExtras(setlistTrack);

      await _audioHandler.addQueueItem(MediaItem(
          id: await TempoRepository().getClickTrackPath(setlistTrack.trackId!),
          album: setlist?.description ?? '',
          title: setlistTrack.plTrack?.title ?? '',
          extras: extras,
          artist: setlist?.location ?? ''));
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
    if (isLastSelected) {
      return;
    }
    _audioHandler.skipToNext();
  }

  void skipToPrevious() {
    if (isFirstSelected) {
      return;
    }
    _audioHandler.skipToPrevious();
  }

  void startSetList() {
    if (setlistProgress.startTime != null) {
      // Already started, so hopefully is paused
      if (setlistProgress.pauseTimes.isNotEmpty &&
          setlistProgress.pauseTimes.last.end == null) {
        setlistProgress.pauseTimes.last.end =
            DateTime.now().millisecondsSinceEpoch;
      }
      return;
    }
    setlistProgress.startTime = DateTime.now().millisecondsSinceEpoch;
    syncSetlistProgress();

    setlistProgressTimer?.cancel();
    setlistProgressTimer =
        Timer.periodic(const Duration(milliseconds: 250), (Timer timer) {
      syncSetlistProgress();
    });
  }

  void pauseSetList() {
    if (setlistProgress.startTime == null) {
      return;
    }
    setlistProgress.pauseTimes
        .add(TimeRange(start: DateTime.now().millisecondsSinceEpoch));

    syncSetlistProgress();
  }

  void stopSetList() {
    setlistProgress.startTime = null;
    setlistProgress.pauseTimes.clear();
    setlistProgressController.sink.add(setlistProgress);
    setlistProgressTimer?.cancel();
  }

  @override
  Future<void> dispose() async {
    await _audioHandler.stop();
    await _audioHandler.customAction('clear');
    audioQueueItemListener.cancel();
    indicatorStateBloc.dispose();
    setlistProgressTimer?.cancel();
    setlistProgressController.close();
  }
}
