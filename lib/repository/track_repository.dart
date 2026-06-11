import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/model/table_base_override.dart';
import 'package:in_the_pocket/repository/repository_base.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';
import 'package:uuid/uuid.dart';

class TrackRepository extends RepositoryBase<SetlistTrack> {
  final double msToMinutes = 60000.0;

  @override
  Future<List<SetlistTrack>> fetch(
      {bool Function(SetlistTrack)? filter,
      String? whereClause,
      String? whereParameter}) async {
    SetlistTrackFilterBuilder setlistTrackQuery = SetlistTrack().select();
    if (whereClause != null) {
      setlistTrackQuery =
          setlistTrackQuery.where(whereClause, parameterValue: whereParameter);
    }

    List<SetlistTrack> setlistTracks = await setlistTrackQuery
        .orderBy(TableBase.SORT_ORDER_COLUMN)
        .toList(preload: true);

    if (filter != null) {
      setlistTracks = setlistTracks.where(filter).toList();
    }

    return setlistTracks;
  }

  @override
  Future<String> upsert(SetlistTrack item,
      {bool writeClickTrack = true}) async {
    item.trackId ??= item.plTrack!.id;
    item.sortOrder ??= await SetlistTrack().select().toCount() + 1;
    item.upsert();
    item.plTrack!.upsert();

    final TempoRepository tempoRepository = TempoRepository();

    final List<Tempo> existingTempos = await tempoRepository.fetch(
        whereClause: 'trackId == ?', whereParameter: item.trackId);

    // Load tempos if we don't already have a handle to the list.
    // If we have a handle already, plTempos won't match existing tempos,
    // and we need to reconcile all changes.
    item.plTrack!.plTempos ??= existingTempos;

    final Map<String, Tempo> newTempoMap = <String, Tempo>{};

    // Verify and save all tempos
    for (Tempo tempo in item.plTrack!.plTempos!) {
      tempo.trackId = item.trackId!;
      await tempoRepository.upsert(tempo);
      newTempoMap[tempo.id!] = tempo;
    }

    // Delete anything that was removed from our list.
    for (Tempo existing in existingTempos) {
      if (!newTempoMap.containsKey(existing.id!)) {
        await tempoRepository.delete(existing.id!);
      }
    }

    // Now write our click track, unless this is explicitly skipped.
    // We will skip when importing a track using bulk import, because it will already be there.
    if (writeClickTrack) {
      if (item.plTrack!.plTempos == null || item.plTrack!.plTempos!.isEmpty) {
        // If there are no tempos, we should delete any existing click track and skip writing a new one.
        await tempoRepository.writeEmptyClickTrack(item.trackId!);
      } else {
        await tempoRepository.writeClickTracks(tempos: item.plTrack!.plTempos!);
      }
    }

    return item.id!;
  }

  @override
  Future<void> delete(String id) async {
    final SetlistTrack? current = await SetlistTrack().getById(id);

    // If it is null, it means we've already deleted but must have
    // accidentally double-invoked the deletion or attempted a deletion on a stale list.
    if (current == null) {
      return;
    }

    final List<SetlistTrack> setListTracksWithCurrent = await SetlistTrack()
        .select()
        .where("trackId = '${current.trackId}' and row__id != '$id'")
        .toList();

    Track? trackToDelete;

    if (setListTracksWithCurrent.isEmpty) {
      trackToDelete = await Track().getById(current.trackId);
      final TempoRepository tempoRepository = TempoRepository();
      final List<Tempo> tempos = await tempoRepository.fetch(
          whereClause: 'trackId == ?', whereParameter: current.trackId);
      for (Tempo tempo in tempos) {
        await tempo.delete();
      }
      await tempoRepository.deleteClickTrack(current.trackId!);
    }
    await current.delete();

    // delete track last to not break foreign keys with tempo or set list track.
    await trackToDelete?.delete();
  }

  Future<Track> getTrackById(String id) async {
    return await Track().getById(id) as Track;
  }

  Future<List<Track>> getTracks(
      {bool preload = false,
      List<String>? preloadFields,
      bool loadParents = false,
      List<String>? loadedFields}) async {
    return await Track().select().toList(
        preload: preload,
        preloadFields: preloadFields,
        loadParents: loadParents,
        loadedFields: loadedFields);
  }

  Future<String> insertTrack(Track track) async {
    track.id ??= const Uuid().v4();
    await track.upsert();
    return track.id!;
  }
}
