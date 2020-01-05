import 'package:in_the_pocket/models/independent/tempo.g.m8.dart';
import 'package:in_the_pocket/repository/repository_base.dart';

class TempoRepository extends RepositoryBase<TempoProxy> {
  @override
  Future<List<TempoProxy>> fetch({Function filter}) async {
    List<TempoProxy> tempos = await dbProvider.getTempoProxiesAll();

    if (filter != null) {
      tempos = tempos.where(filter).toList();
    }

    tempos.sort(
        (TempoProxy a, TempoProxy b) => a.sortOrder.compareTo(b.sortOrder));
    return tempos;
  }

  @override
  Future<int> insert(TempoProxy item) async {
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
      if (tempo.trackId == -1) {
        dbProvider.deleteTempo(tempo.id);
      }
    }
  }
}
