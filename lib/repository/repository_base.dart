import 'package:in_the_pocket/main.adapter.g.m8.dart';
import 'package:in_the_pocket/models/independent/model_base.dart';
import 'package:uuid/uuid.dart';

abstract class RepositoryBase<T extends ModelBase> {
  DatabaseProvider get dbProvider {
    return DatabaseProvider(DatabaseAdapter());
  }

  Future<List<T>> fetch({Function filter});

  Future<void> prepareInsert(T item) async {
    item.guid = Uuid().v4();
  }

  Future<int> insert(T item);

  Future<int> update(T item);

  Future<int> delete(int id);
}
