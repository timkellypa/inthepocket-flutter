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
  Future<String> insert(SetlistTrack item) async {
    item.init();

    item.plTrack ??= (await Track().getById(item.trackId)) ?? Track();
    item.plTrack!.init();

    // Save any nested tempos that were provided
    if (item.plTrack?.plTempos != null && item.plTrack!.plTempos!.isNotEmpty) {
      for (Tempo tempo in item.plTrack!.plTempos!) {
        tempo.trackId = item.plTrack!.id;
        await tempo.upsert();
      }
    }

    item.trackId = item.plTrack!.id;
    item.sortOrder = await SetlistTrack().select().toCount() + 1;
    await item.upsert();
    await item.plTrack?.upsert();

    final List<Tempo>? tempos = item.plTrack?.plTempos ??
        await Tempo()
            .select()
            .where("trackId = '${item.plTrack?.id}'")
            .toList();

    if (tempos == null || tempos.isEmpty) {
      TempoRepository().writeEmptyClickTrack(item.trackId!);
    } else {
      TempoRepository().writeClickTracks(
        tempos: tempos,
        notify: (int total, double progress) {
          // TODO(timkellypa): Create progress notifier here.
        },
      );
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
