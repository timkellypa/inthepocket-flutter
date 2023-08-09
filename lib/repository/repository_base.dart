import 'package:in_the_pocket/model/model_base.dart';

abstract class RepositoryBase<T extends ModelBase> {
  /// Fetches a list of models.
  /// filter can be used to filter models.
  /// whereClause can be used to do a SQL where clause for sqflite selections,
  /// unsupported by things like the spotify playlists, etc.
  Future<List<T>> fetch({
    bool Function(T)? filter, 
    String? whereClause,
    String? whereParameter
  });

  Future<String> insert(T item);

  Future<String> update(T item);

  Future<void> delete(String id);
}
