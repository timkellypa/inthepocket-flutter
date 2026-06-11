import 'package:in_the_pocket/model/model_base.dart';
import 'package:in_the_pocket/providers/spotify_provider.dart';
import 'package:in_the_pocket/repository/repository_base.dart';

abstract class SpotifyRepositoryBase<T extends ModelBase>
    implements RepositoryBase<T> {
  SpotifyProvider get spotifyProvider {
    return SpotifyProvider();
  }

  @override
  Future<void> delete(String id) {
    throw UnimplementedError('Cannot delete from spotify');
  }

  @override
  Future<String> upsert(T item) {
    throw UnimplementedError('Cannot insert to spotify');
  }
}
