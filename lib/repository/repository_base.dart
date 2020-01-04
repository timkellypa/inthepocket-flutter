import 'package:in_the_pocket/main.adapter.g.m8.dart';

abstract class RepositoryBase<T> {
  DatabaseProvider get dbProvider {
    return DatabaseProvider(DatabaseAdapter());
  }

  Future<List<T>> fetch({Function filter});

  Future<int> insert(T item);

  Future<int> update(T item);

  Future<int> delete(int id);
}
