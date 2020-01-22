import 'dart:io';

import 'package:in_the_pocket/classes/MetronomeWriter.dart';
import 'package:in_the_pocket/models/independent/tempo.g.m8.dart';
import 'package:in_the_pocket/repository/repository_base.dart';
import 'package:in_the_pocket/repository/track_repository.dart';
import 'package:path_provider/path_provider.dart';

class TempoRepository extends RepositoryBase<TempoProxy> {
  Future<String> get _localPath async {
    final Directory directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<String> get _tempoDirectory async {
    return '${await _localPath}/click_tracks';
  }

  Future<String> getClickTrackPath(int trackId) async {
    return '${await _tempoDirectory}/${trackId.toString()}.wav';
  }

  @override
  Future<List<TempoProxy>> fetch({Function filter}) async {
    List<TempoProxy> tempos = await dbProvider.getTempoProxiesAll();

    if (filter != null) {
      tempos = tempos.where(filter).toList();
    }

    tempos.sort((TempoProxy a, TempoProxy b) {
      final int trackComparison = a.trackId.compareTo(b.trackId);
      if (trackComparison == 0) {
        return a.sortOrder.compareTo(b.sortOrder);
      }
      return trackComparison;
    });
    return tempos;
  }

  @override
  Future<int> insert(TempoProxy item) async {
    await prepareInsert(item);
    final int id = await dbProvider.saveTempo(item);
    item.id = id;
    item.sortOrder = id;
    return await dbProvider.updateTempo(item);
  }

  @override
  Future<int> update(TempoProxy item) => dbProvider.updateTempo(item);

  @override
  Future<int> delete(int id) => dbProvider.deleteTempo(id);

  Future<void> clearPlaceholderTempos() async {
    final List<TempoProxy> tempos = await dbProvider.getTempoProxiesAll();
    for (TempoProxy tempo in tempos) {
      if (tempo.trackId == TrackRepository.NEW_TRACK_ID) {
        dbProvider.deleteTempo(tempo.id);
      }
    }
  }

  Future<void> _writeClickTrackToFile(
      int trackId, MetronomeWriter writer) async {
    final String path = await getClickTrackPath(trackId);
    final File file = File(path);

    if (file.existsSync()) {
      await file.delete();
    }
    await file.create(recursive: true);
    await file.writeAsBytes(writer.fileBytes);
  }

  Future<void> writeClickTracks({List<TempoProxy> tempos}) async {
    int previousTrack;
    tempos ??= await fetch();
    if (tempos.isEmpty) {
      return;
    }
    MetronomeWriter writer = MetronomeWriter();
    for (TempoProxy tempo in tempos) {
      if (tempo.trackId != previousTrack) {
        // if next track is new, write the contents of writer
        // and create a new one to keep going
        await _writeClickTrackToFile(previousTrack, writer);
        writer = MetronomeWriter();
      }
      await writer.addTempo(tempo);
      previousTrack = tempo.trackId;
    }
    // After the loop write the last file contents, and de-reference writer
    await _writeClickTrackToFile(previousTrack, writer);
    writer = null;
  }
}
