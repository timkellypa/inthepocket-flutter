import 'dart:io';

import 'package:in_the_pocket/classes/MetronomeWriter.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/model/table_base_override.dart';
import 'package:in_the_pocket/repository/repository_base.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wave_builder/wave_builder.dart';

class TempoRepository extends RepositoryBase<Tempo> {
  Future<String> get _localPath async {
    final Directory directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<String> get _tempoDirectory async {
    return '${await _localPath}/click_tracks';
  }

  Future<String> getClickTrackPath(String trackId) async {
    return '${await _tempoDirectory}/$trackId.wav';
  }

  String getTrackIdFromPath(String path) {
    final List<String> pathItems = path.split('/');
    return pathItems.last.split('.')[0];
  }

  @override
  Future<List<Tempo>> fetch(
      {bool Function(Tempo)? filter,
      String? whereClause,
      String? whereParameter}) async {
    TempoFilterBuilder tempoQuery = Tempo().select();

    if (whereClause != null) {
      tempoQuery =
          tempoQuery.where(whereClause, parameterValue: whereParameter);
    }

    List<Tempo> tempos =
        await tempoQuery.orderBy(TableBase.SORT_ORDER_COLUMN).toList();

    if (filter != null) {
      tempos = tempos.where(filter).toList();
    }

    return tempos;
  }

  @override
  Future<String> insert(Tempo item) async {
    item.init();
    item.sortOrder = await Tempo().select().toCount() + 1;
    await item.upsert();
    return item.id!;
  }

  @override
  Future<String> update(Tempo item) async {
    await item.upsert();
    return item.id!;
  }

  @override
  Future<void> delete(String id) async {
    final Tempo tempo = await Tempo().getById(id) as Tempo;
    await tempo.delete();
  }

  Future<void> _writeClickTrackToFile(
      String trackId, MetronomeWriter writer) async {
    final String path = await getClickTrackPath(trackId);
    final File file = File(path);

    if (file.existsSync()) {
      await file.delete();
    }
    await file.create(recursive: true);
    await file.writeAsBytes(writer.fileBytes);
  }

  Future<void> writeEmptyClickTrack(String trackId) async {
    final MetronomeWriter writer = MetronomeWriter();
    writer.appendSilence(60000, WaveBuilderSilenceType.BeginningOfLastSample);
    await _writeClickTrackToFile(trackId, writer);
  }

  Future<void> writeClickTracks(
      {required List<Tempo> tempos,
      required Function(int total, double progress) notify}) async {
    String? previousTrack;
    double i = 0;
    notify(tempos.length, i);
    MetronomeWriter writer = MetronomeWriter();

    for (Tempo tempo in tempos) {
      if (tempo.trackId != previousTrack && previousTrack != null) {
        // if next track is new, write the contents of writer
        // and create a new one to keep going
        await _writeClickTrackToFile(previousTrack, writer);
        writer = MetronomeWriter();
      }
      await writer.addTempo(tempo);
      previousTrack = tempo.trackId;
      notify(tempos.length, i++);
    }

    // After the loop write the last file contents, and de-reference writer
    await _writeClickTrackToFile(previousTrack!, writer);
    notify(tempos.length, tempos.length * 1.0);
  }

  Future<void> deleteClickTrack(String trackId) async {
    final String path = await getClickTrackPath(trackId);
    final File file = File(path);

    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// Get the display text for the tempo.
  /// Would normally be an instance method in the tempo model,
  /// but I don't have that kind of access to the generated model.
  String getTempoDisplayText(Tempo tempo) {
    return '${tempo.bpm} BPM (${tempo.beatsPerBar}/${tempo.beatUnit})';
  }

  static bool isCountPrimary(Tempo tempo, int count) {
    if (tempo.beatsPerBar == null ||
        tempo.accentBeatsPerBar == null ||
        count == 0) {
      return false;
    }
    return ((count - 1) % (tempo.beatsPerBar! / tempo.accentBeatsPerBar!)) == 0;
  }
}
