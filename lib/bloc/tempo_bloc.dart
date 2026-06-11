import 'dart:async';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';

import 'model_bloc_base.dart';

/// The [TempoBloc] manages the list of tempos for a given track.
/// Note, this bloc is different than other blocs, because it keeps the list locally
/// and does not interact directly with a repository.
/// This is by design, so the track can be responsible for CRUD operations on the tempos set
/// as well as writing the click track, which is a cumulative file encapsulating all tempos.
/// Side Effect: Populates plTempos on the provided track if not already populated.
class TempoBloc extends ModelBlocBase<Tempo, TempoRepository> {
  TempoBloc(this.track) : super();

  final Track track;

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
    return 'Tempos';
  }

  @override
  Future<List<Tempo>> getItemList({bool Function(Tempo)? filter}) async {
    if (track.plTempos == null) {
      // Load tempos onto provided track.
      final TempoRepository tempoRepository = TempoRepository();
      track.plTempos = await tempoRepository.fetch(filter: listFilter);
    }
    return track.plTempos!.toList();
  }

  @override
  Future<void> upsert(Tempo item) async {
    final int existingIndex =
        track.plTempos?.indexWhere((Tempo tempo) => tempo.id == item.id) ?? -1;
    if (existingIndex != -1) {
      track.plTempos
          ?.replaceRange(existingIndex, existingIndex + 1, <Tempo>[item]);
    } else {
      track.plTempos?.add(item);
    }
    fetch();
  }

  @override
  Future<void> delete(Tempo item) async {
    track.plTempos?.removeWhere((Tempo tempo) => tempo.id == item.id);
    fetch();
  }

  @override
  Future<Tempo> buildNewItem() async {
    final Tempo tempo = Tempo().init() as Tempo;
    tempo.trackId = track.id!;
    tempo.sortOrder = await Tempo().select().toCount() + 1;
    tempo.numberOfBars = null;
    return tempo;
  }
}
