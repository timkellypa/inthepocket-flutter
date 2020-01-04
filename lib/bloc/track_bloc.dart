import 'dart:async';
import 'dart:collection';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';
import 'package:in_the_pocket/models/independent/track.g.m8.dart';
import 'package:in_the_pocket/repository/track_repository.dart';

import 'model_bloc_base.dart';

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
          await getItemList(filter: importExclusionsFilter);

      final HashMap<SetListTrackProxy, ItemSelection> itemSelections =
          HashMap<SetListTrackProxy, ItemSelection>();

      // create reverse lookup for existing tracks
      final HashMap<String, SetListTrackProxy> existingTrackMap =
          HashMap<String, SetListTrackProxy>.fromEntries(existingTracks.map(
              (SetListTrackProxy track) => MapEntry<String, SetListTrackProxy>(
                  track.trackId.toString(), track)));

      for (SetListTrackProxy setListTrack in setListTracks) {
        if (existingTrackMap.containsKey(setListTrack.trackId.toString())) {
          selectItem(itemSelections, setListTrack, SelectionType.disabled,
              doSync: false);
        }
      }

      syncSelections(itemSelections);
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
}
