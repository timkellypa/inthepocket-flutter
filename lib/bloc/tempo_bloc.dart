import 'dart:async';
import 'package:in_the_pocket/models/independent/tempo.g.m8.dart';
import 'package:in_the_pocket/models/independent/track.g.m8.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';

import 'model_bloc_base.dart';

class TempoBloc extends ModelBlocBase<TempoProxy, TempoRepository> {
  TempoBloc(this.track) : super();

  final TrackProxy track;

  bool firstFetch = true;

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

  @override
  Future<void> insert(TempoProxy item) async {
    await repository.insert(item);
    fetch();
  }

  @override
  Future<void> update(TempoProxy item) async {
    await repository.update(item);
    fetch();
  }

  @override
  Future<void> delete(TempoProxy item) async {
    await repository.delete(item.id);
    fetch();
  }

  Future<void> clearPlaceholderTempos() async {
    await repository.clearPlaceholderTempos();
  }
}
