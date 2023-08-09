import 'dart:async';
import 'dart:collection';

import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/model/spotify_playlist.dart';
import 'package:in_the_pocket/model/spotify_track.dart';
import 'package:in_the_pocket/repository/spotify_track_repository.dart';
import 'package:in_the_pocket/repository/track_repository.dart';

import 'model_bloc_base.dart';

class SaveStatus {
  SaveStatus(this.total, this.progress);

  final int total;
  final double progress;
}

class SpotifyTrackBloc
    extends ModelBlocBase<SpotifyTrack, SpotifyTrackRepository> {
  SpotifyTrackBloc(this.spotifyPlaylist, {required this.importTargetSetlist}) : super();

  final Setlist? importTargetSetlist;
  final SpotifyPlaylist? spotifyPlaylist;

  bool firstFetch = true;

  @override
  SpotifyTrackRepository get repository {
    return SpotifyTrackRepository(spotifyPlaylist: spotifyPlaylist);
  }

  @override
  String get listTitle {
    return spotifyPlaylist?.spotifyTitle ?? '';
  }

  @override
  Future<List<SpotifyTrack>> fetch() async {
    final List<SpotifyTrack> spotifyTracks = await getItemList();
    if (firstFetch) {
      firstFetch = false;

      final TrackBloc trackBloc = TrackBloc(importTargetSetlist);

      final List<SetlistTrack> setlistTracks =
          await trackBloc.getItemList();

      final HashMap<String, SetlistTrack> spotifyIdSetlistTrackMap =
          HashMap<String, SetlistTrack>();

      for (SetlistTrack setlistTrack in setlistTracks) {
        if (setlistTrack.plTrack?.spotifyId != null) {
          spotifyIdSetlistTrackMap[setlistTrack.plTrack!.spotifyId!] = setlistTrack;
        }
      }

      for (SpotifyTrack spotifyTrack in spotifyTracks) {
        if (spotifyIdSetlistTrackMap.containsKey(spotifyTrack.spotifyId)) {
          selectItem(spotifyTrack, SelectionType.disabled);
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
    await repository.delete(item.id!);
    fetch();
  }

  Future<void> importItems(Setlist targetSetlist,
      HashMap<String, ItemSelection> selectedItemMap) async {
    // Start progress indicator immediately at 0.
    //  Will only start progressing after click tracks are being written,
    //  Since that is the most time-consuming part of the save.
    updateSaveStatus(1, 0.0);
    final List<SpotifyTrack> entries = itemList
        .where((SpotifyTrack spotifyTrack) =>
            selectedItemMap.containsKey(spotifyTrack.id) &&
            selectedItemMap[spotifyTrack.id]!.selectionType &
                    SelectionType.selected >
                0)
        .toList();
    final List<Track> audioFeatureTracks = <Track>[];

    entries.sort(
        (SpotifyTrack a, SpotifyTrack b) => a.sortOrder!.compareTo(b.sortOrder!));

    final TrackRepository trackRepository = TrackRepository();
    final List<Track> trackList = await trackRepository.getTracks();

    // generate a reverse lookup tracklist by spotify id
    final HashMap<String, Track> spotifyIdTrackMap =
        HashMap<String, Track>();

    for (Track track in trackList) {
      spotifyIdTrackMap[track.spotifyId!] = track;
    }

    for (SpotifyTrack spotifyTrack in entries) {
      Track track;
      // check to see if it already exists
      if (!spotifyIdTrackMap.containsKey(spotifyTrack.spotifyId)) {
        track = Track();
        track.spotifyId = spotifyTrack.spotifyId;
        track.title = spotifyTrack.spotifyTitle;
        track.spotifyAudioFeatures = spotifyTrack.spotifyAudioFeatures;
        final String trackId = await trackRepository.insertTrack(track);
        track.id = trackId;
        audioFeatureTracks.add(track);
      } else {
        track = spotifyIdTrackMap[spotifyTrack.spotifyId]!;
      }

      final SetlistTrack setlistTrack = SetlistTrack();

      setlistTrack.trackId = track.id;
      setlistTrack.setlistId = targetSetlist.id;
      await trackRepository.insert(setlistTrack);
    }
    await trackRepository.applySpotifyAudioFeatures(audioFeatureTracks,
        notify: updateSaveStatus);
    updateSaveStatus(0, 0);
  }
}
