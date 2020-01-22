import 'package:in_the_pocket/main.adapter.g.m8.dart';
import 'package:in_the_pocket/models/independent/model_base.dart';
import 'package:in_the_pocket/providers/spotify_provider.dart';
import 'package:in_the_pocket/repository/repository_base.dart';

abstract class SpotifyRepositoryBase<T extends ModelBase>
    implements RepositoryBase<T> {
  @override
  DatabaseProvider get dbProvider => null;

  SpotifyProvider get spotifyProvider {
    return SpotifyProvider();
  }

  @override
  Future<void> prepareInsert(T item) {
    throw UnimplementedError('Cannot insert to spotify');
  }

  @override
  Future<int> delete(int id) {
    throw UnimplementedError('Cannot delete from spotify');
  }

  @override
  Future<int> insert(T item) {
    throw UnimplementedError('Cannot insert to spotify');
  }

  @override
  Future<int> update(T item) {
    throw UnimplementedError('Cannot update in spotify');
  }
}
