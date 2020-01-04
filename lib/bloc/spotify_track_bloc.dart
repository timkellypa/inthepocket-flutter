import 'dart:async';
import 'dart:collection';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';
import 'package:in_the_pocket/models/independent/spotify_playlist.dart';
import 'package:in_the_pocket/models/independent/spotify_track.dart';
import 'package:in_the_pocket/models/independent/track.g.m8.dart';
import 'package:in_the_pocket/repository/spotify_track_repository.dart';
import 'package:in_the_pocket/repository/track_repository.dart';

import 'model_bloc_base.dart';

class SpotifyTrackBloc
    extends ModelBlocBase<SpotifyTrack, SpotifyTrackRepository> {
  SpotifyTrackBloc(this.spotifyPlaylist, {this.importTargetSetList}) : super();

  final SetListProxy importTargetSetList;
  final SpotifyPlaylist spotifyPlaylist;

  bool firstFetch = true;

  @override
  SpotifyTrackRepository get repository {
    return SpotifyTrackRepository(spotifyPlaylist: spotifyPlaylist);
  }

  @override
  String get listTitle {
    return spotifyPlaylist.spotifyTitle;
  }

  @override
  Future<List<SpotifyTrack>> fetch() async {
    final List<SpotifyTrack> spotifyTracks = await getItemList();
    if (importTargetSetList != null && firstFetch) {
      firstFetch = false;

      final HashMap<SpotifyTrack, ItemSelection> itemSelections =
          HashMap<SpotifyTrack, ItemSelection>();

      final TrackBloc trackBloc = TrackBloc(importTargetSetList);

      final List<SetListTrackProxy> setListTracks =
          await trackBloc.getItemList();

      final HashMap<String, SetListTrackProxy> spotifyIdSetListTrackMap =
          HashMap<String, SetListTrackProxy>();

      for (SetListTrackProxy setListTrack in setListTracks) {
        if (setListTrack.track.spotifyId != null) {
          spotifyIdSetListTrackMap[setListTrack.track.spotifyId] = setListTrack;
        }
      }

      for (SpotifyTrack spotifyTrack in spotifyTracks) {
        if (spotifyIdSetListTrackMap.containsKey(spotifyTrack.spotifyId)) {
          selectItem(itemSelections, spotifyTrack, SelectionType.disabled);
        }
      }
    }

    listController.sink.add(spotifyTracks);
    return spotifyTracks;
  }

  @override
  Future<void> insert(SpotifyTrack item) async {
    await repository.insert(item);
    fetch();
  }

  @override
  Future<void> update(SpotifyTrack item) async {
    await repository.update(item);
    fetch();
  }

  @override
  Future<void> delete(SpotifyTrack item) async {
    await repository.delete(item.id);
    fetch();
  }

  Future<void> importItems(SetListProxy targetSetList,
      HashMap<SpotifyTrack, ItemSelection> selectedItemMap) async {
    final List<MapEntry<SpotifyTrack, ItemSelection>> entries =
        selectedItemMap.entries.toList();
    final List<TrackProxy> audioFeatureTracks = <TrackProxy>[];

    entries.sort((MapEntry<SpotifyTrack, ItemSelection> a,
            MapEntry<SpotifyTrack, ItemSelection> b) =>
        a.key.sortOrder.compareTo(b.key.sortOrder));

    final TrackRepository trackRepository = TrackRepository();
    final List<TrackProxy> trackList = await trackRepository.getTracks();

    // generate a reverse lookup tracklist by spotify id
    final HashMap<String, TrackProxy> spotifyIdTrackMap =
        HashMap<String, TrackProxy>();

    for (TrackProxy track in trackList) {
      spotifyIdTrackMap[track.spotifyId] = track;
    }

    for (MapEntry<SpotifyTrack, ItemSelection> entry in entries) {
      if (entry.value.selectionType & SelectionType.selected > 0) {
        TrackProxy track;
        // check to see if it already exists
        if (!spotifyIdTrackMap.containsKey(entry.key.spotifyId)) {
          track = TrackProxy();
          track.spotifyId = entry.key.spotifyId;
          track.title = entry.key.spotifyTitle;
          track.spotifyAudioFeatures = entry.key.spotifyAudioFeatures;
          final int trackId = await trackRepository.insertTrack(track);
          track.id = trackId;
          audioFeatureTracks.add(track);
        } else {
          track = spotifyIdTrackMap[entry.key.spotifyId];
        }

        final SetListTrackProxy setListTrack = SetListTrackProxy();

        setListTrack.trackId = track.id;
        setListTrack.setListId = targetSetList.id;
        await trackRepository.insert(setListTrack);
      }
    }
    await trackRepository.applySpotifyAudioFeatures(audioFeatureTracks);
  }
}
