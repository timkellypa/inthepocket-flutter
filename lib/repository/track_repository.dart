import 'dart:collection';
import 'dart:convert';

import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/model/table_base_override.dart';
import 'package:in_the_pocket/providers/spotify_provider.dart';
import 'package:in_the_pocket/repository/repository_base.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';
import 'package:uuid/uuid.dart';

class TrackRepository extends RepositoryBase<SetlistTrack> {
  static const int NEW_TRACK_ID = -1;
  final double msToMinutes = 60000.0;

  @override
  Future<List<SetlistTrack>> fetch({
    bool Function(SetlistTrack)? filter, 
    String? whereClause,
    String? whereParameter
  }) async {
    SetlistTrackFilterBuilder setlistTrackQuery = SetlistTrack().select();
    if (whereClause != null) {
      setlistTrackQuery = setlistTrackQuery.where(whereClause, parameterValue: whereParameter);
    }

    List<SetlistTrack> setlistTracks = await setlistTrackQuery.orderBy(TableBase.SORT_ORDER_COLUMN).toList(preload: true);

    if (filter != null) {
      setlistTracks = setlistTracks.where(filter).toList();
    }

    return setlistTracks;
  }

  @override
  Future<String> insert(SetlistTrack item) async {
    item.init();
    item.plTrack!.init();
    item.trackId = item.plTrack!.id;
    item.sortOrder = await SetlistTrack().select().toCount() + 1;
    await item.upsert();
    await item.plTrack?.upsert();

    final List<Tempo>? tempos = item.plTrack?.plTempos;

    if (tempos == null || tempos.isEmpty) {
      TempoRepository().writeEmptyClickTrack(item.trackId!);
    } else {
      TempoRepository().writeClickTracks(tempos: tempos, notify: (int total, double progress) {
        // TODO(timkellypa): Create progress notifier here.
      },);
    }
    return item.id!;
  }

  @override
  Future<String> update(SetlistTrack item) async {
    // at this point, we can assume item has an ID and a track.
    item.upsert();
    item.plTrack!.upsert();
    return item.id!;
  }

  @override
  Future<void> delete(String id) async {
    final SetlistTrack current = SetlistTrack().getById(id) as SetlistTrack;

    final List<SetlistTrack> setListTracksWithCurrent = await SetlistTrack().select().where("trackId = '${current.trackId}' and id != '$id'").toList();

    if (setListTracksWithCurrent.isEmpty) {
      await (await Track().getById(id))?.delete();
      final TempoRepository tempoRepository = TempoRepository();
      final List<Tempo> tempos = await tempoRepository.fetch(
          whereClause: 'trackId == ?', whereParameter: current.trackId);
      for (Tempo tempo in tempos) {
        await tempo.delete();
      }
      await tempoRepository.deleteClickTrack(current.trackId!);
    }
    await current.delete();
  }

  Future<Track> getTrackById(String id) async {
    return await Track().getById(id) as Track;
  }

  Future<List<Track>> getTracks() async {
    return await Track().select().toList();
  }

  Future<String> insertTrack(Track track) async {
    track.id ??= const Uuid().v4();
    await track.upsert();
    return track.id!;
  }

  Future<void> applySpotifyAudioFeatures(List<Track> tracks,
      {required void Function(int total, double progress) notify
  }) async {
    final HashMap<String, Track> idTrackMap =
        HashMap<String, Track>();
    final TempoRepository tempoRepository = TempoRepository();
    final List<Tempo> temposToSave = <Tempo>[];
    final List<Tempo> existingTempos =
        await Tempo().select().toList();

    for (Track track in tracks) {
      idTrackMap[track.id.toString()] = track;
      if (track.spotifyAudioFeatures != null && track.spotifyId != null) {
        idTrackMap[track.id.toString()] = track;
        track.spotifyAudioFeatures =
            await SpotifyProvider().getAudioFeaturesJSON(track.spotifyId!);
        await Track().save();

        if (track.spotifyAudioFeatures != '') {
          final Map<String, dynamic> audioFeatures =
              json.decode(track.spotifyAudioFeatures!);
          final Tempo tempo = _buildTempoFromAudioFeatures(audioFeatures);
          tempo.trackId = track.id;

          temposToSave.add(tempo);
        }
      }
    }

    for (Tempo tempo in existingTempos) {
      if (idTrackMap.containsKey(tempo.trackId)) {
        await tempoRepository.delete(tempo.id!);
      }
    }

    for (Tempo tempo in temposToSave) {
      await tempoRepository.insert(tempo);
    }

    // no click tracks to write, just exit.
    if (temposToSave.isEmpty) {
      return;
    }

    await tempoRepository.writeClickTracks(
        tempos: temposToSave, notify: notify);
  }

  Tempo _buildTempoFromAudioFeatures(Map<String, dynamic> audioFeatures) {
    final Tempo tempo = Tempo();
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
        duration * tempo.bpm! / (msToMinutes * tempo.beatsPerBar!);
    return tempo;
  }
}
