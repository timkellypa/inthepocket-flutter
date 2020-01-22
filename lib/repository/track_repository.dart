import 'dart:collection';
import 'dart:convert';

import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';
import 'package:in_the_pocket/models/independent/track.g.m8.dart';
import 'package:in_the_pocket/models/independent/tempo.g.m8.dart';
import 'package:in_the_pocket/providers/spotify_provider.dart';
import 'package:in_the_pocket/repository/repository_base.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';
import 'package:uuid/uuid.dart';

class TrackRepository extends RepositoryBase<SetListTrackProxy> {
  static const int NEW_TRACK_ID = -1;
  final double msToMinutes = 60000.0;

  @override
  Future<List<SetListTrackProxy>> fetch({Function filter}) async {
    List<SetListTrackProxy> tracks =
        await dbProvider.getSetListTrackProxiesAll();

    if (filter != null) {
      tracks = tracks.where(filter).toList();
    }
    tracks.sort((SetListTrackProxy a, SetListTrackProxy b) =>
        a.sortOrder.compareTo(b.sortOrder));

    for (SetListTrackProxy track in tracks) {
      track.track = await getTrackById(track.trackId);
    }

    return tracks;
  }

  @override
  Future<int> insert(SetListTrackProxy item) async {
    await prepareInsert(item);
    final int id = await dbProvider.saveSetListTrack(item);
    item.id = id;
    item.sortOrder = id;

    if (item.trackId != null && item.track != null) {
      await dbProvider.updateTrack(item.track);
    } else if (item.track != null) {
      item.track.guid = Uuid().v4();
      final int trackId = await dbProvider.saveTrack(item.track);
      item.trackId = trackId;

      // Grab any tempos that are currently -1 for track ID (placeholder)
      final List<TempoProxy> tempos = await dbProvider.getTempoProxiesAll();
      for (TempoProxy tempo in tempos) {
        if (tempo.trackId == NEW_TRACK_ID) {
          tempo.trackId = trackId;
          await dbProvider.updateTempo(tempo);
        }
      }
      TempoRepository().writeClickTracks(tempos: tempos);
    }

    return await dbProvider.updateSetListTrack(item);
  }

  @override
  Future<int> update(SetListTrackProxy item) async {
    final int ret = await dbProvider.updateSetListTrack(item);
    await dbProvider.updateTrack(item.track);
    return ret;
  }

  @override
  Future<int> delete(int id) async {
    final SetListTrackProxy current = await dbProvider.getSetListTrack(id);

    final List<SetListTrackProxy> setListTracks =
        await dbProvider.getSetListTrackProxiesAll();

    final List<SetListTrackProxy> setListTracksWithCurrent = setListTracks
        .where((SetListTrackProxy setListTrack) =>
            setListTrack.trackId == current.trackId && setListTrack.id != id)
        .toList();
    if (setListTracksWithCurrent.isEmpty) {
      await dbProvider.deleteTrack(current.trackId);
    }
    return await dbProvider.deleteSetListTrack(id);
  }

  Future<TrackProxy> getTrackById(int id) {
    return dbProvider.getTrack(id);
  }

  Future<List<TrackProxy>> getTracks() {
    return dbProvider.getTrackProxiesAll();
  }

  Future<int> insertTrack(TrackProxy track) async {
    return await dbProvider.saveTrack(track);
  }

  Future<void> applySpotifyAudioFeatures(List<TrackProxy> tracks) async {
    final HashMap<String, TrackProxy> idTrackMap =
        HashMap<String, TrackProxy>();
    final List<TempoProxy> temposToSave = <TempoProxy>[];
    final List<TempoProxy> existingTempos =
        await dbProvider.getTempoProxiesAll();

    for (TrackProxy track in tracks) {
      idTrackMap[track.id.toString()] = track;
      if (track.spotifyAudioFeatures != null) {
        idTrackMap[track.id.toString()] = track;
        track.spotifyAudioFeatures =
            await SpotifyProvider().getAudioFeaturesJSON(track.spotifyId);
        await dbProvider.updateTrack(track);

        if (track.spotifyAudioFeatures != '') {
          final Map<String, dynamic> audioFeatures =
              json.decode(track.spotifyAudioFeatures);
          final TempoProxy tempo = _buildTempoFromAudioFeatures(audioFeatures);
          tempo.trackId = track.id;
          temposToSave.add(tempo);
        }
      }
    }

    for (TempoProxy tempo in existingTempos) {
      if (idTrackMap.containsKey(tempo.trackId)) {
        await dbProvider.deleteTempo(tempo.id);
      }
    }

    for (TempoProxy tempo in temposToSave) {
      await dbProvider.saveTempo(tempo);
    }
    await TempoRepository().writeClickTracks(tempos: temposToSave);
  }

  TempoProxy _buildTempoFromAudioFeatures(Map<String, dynamic> audioFeatures) {
    final TempoProxy tempo = TempoProxy();
    final int duration = audioFeatures['duration_ms'];

    tempo.beatsPerBar = 4;
    tempo.beatUnit = 4;
    tempo.accentBeatsPerBar = 1;
    tempo.dottedQuarterAccent = false;
    tempo.bpm = audioFeatures['tempo'];

    // spotify only provides 1 tempo
    tempo.sortOrder = 1;

    // 3 in spotify indicates 6/8 time.
    if (audioFeatures['time_signature'] == 3) {
      tempo.beatsPerBar = 6;
      tempo.beatUnit = 8;
      tempo.accentBeatsPerBar = 2;
      tempo.dottedQuarterAccent = true;
    }
    tempo.numberOfBars =
        duration * tempo.bpm / (msToMinutes * tempo.beatsPerBar);
    return tempo;
  }
}
