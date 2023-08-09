import 'dart:async';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';

import 'model_bloc_base.dart';

class TempoBloc extends ModelBlocBase<Tempo, TempoRepository> {
  TempoBloc(this.track) : super();

  final Track track;

  bool firstFetch = true;

  @override
  TempoRepository get repository {
    return TempoRepository();
  }

  @override
  bool Function(Tempo) get listFilter {
    return (Tempo proxy) => proxy.trackId == track.id;
  }

  @override
  String get listTitle {
    return '${track.title} tempos';
  }

  @override
  Future<List<Tempo>> fetch({bool updateTempoFile = false}) async {
    final List<Tempo> tempos = await super.fetch();
    track.init();

    // Do not write out click tracks until track is at least saved
    // for the first time
    if (updateTempoFile) {

      if (tempos.isEmpty) {
        await repository.writeEmptyClickTrack(track.id!);
        return tempos;
      }

      await repository.writeClickTracks(tempos: tempos, notify: (int total, double progress) {
        
      },);
    }

    return tempos;
  }

  @override
  Future<void> insert(Tempo item) async {
    await repository.insert(item);
    fetch(updateTempoFile: true);
  }

  @override
  Future<void> update(Tempo item) async {
    await repository.update(item);
    fetch(updateTempoFile: true);
  }

  @override
  Future<void> delete(Tempo item) async {
    await repository.delete(item.id!);
    fetch(updateTempoFile: true);
  }

  Future<void> clearPlaceholderTempos() async {
    await repository.clearPlaceholderTempos();
  }
}
