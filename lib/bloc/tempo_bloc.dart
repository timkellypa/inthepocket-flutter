import 'dart:async';
import 'dart:io';
import 'package:in_the_pocket/classes/MetronomeWriter.dart';
import 'package:in_the_pocket/models/independent/tempo.g.m8.dart';
import 'package:in_the_pocket/models/independent/track.g.m8.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';
import 'package:path_provider/path_provider.dart';

import 'model_bloc_base.dart';

class TempoBloc extends ModelBlocBase<TempoProxy, TempoRepository> {
  TempoBloc(this.track) : super();

  final TrackProxy track;

  bool firstFetch = true;

  Future<String> get _localPath async {
    final Directory directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<String> get _tempoDirectory async {
    return '${await _localPath}/tempos';
  }

  Future<String> get _trackTempoPath async {
    return '${await _tempoDirectory}/${track.id.toString()}.wav';
  }

  @override
  TempoRepository get repository {
    return TempoRepository();
  }

  @override
  Function get listFilter {
    return (TempoProxy proxy) => proxy.trackId == track.id;
  }

  @override
  String get listTitle {
    return '${track.title} tempos';
  }

  Future<void> writeClickTrack({List<TempoProxy> tempos}) async {
    tempos ??= await super.fetch();
    final MetronomeWriter writer = MetronomeWriter();
    for (TempoProxy tempo in tempos) {
      await writer.addTempo(tempo);
    }
    final String path = await _trackTempoPath;
    final File file = File(path);

    if (file.existsSync()) {
      await file.delete();
    }
    await file.create(recursive: true);
    return file.writeAsBytes(writer.fileBytes);
  }

  @override
  Future<List<TempoProxy>> fetch({bool updateTempoFile = false}) async {
    final List<TempoProxy> tempos = await super.fetch();

    if (updateTempoFile) {
      await writeClickTrack(tempos: tempos);
    }

    return tempos;
  }

  @override
  Future<void> insert(TempoProxy item) async {
    await repository.insert(item);
    fetch(updateTempoFile: true);
  }

  @override
  Future<void> update(TempoProxy item) async {
    await repository.update(item);
    fetch(updateTempoFile: true);
  }

  @override
  Future<void> delete(TempoProxy item) async {
    await repository.delete(item.id);
    fetch(updateTempoFile: true);
  }

  Future<void> clearPlaceholderTempos() async {
    await repository.clearPlaceholderTempos();
  }
}
