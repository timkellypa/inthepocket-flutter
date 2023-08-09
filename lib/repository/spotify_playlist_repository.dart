import 'package:in_the_pocket/model/spotify_playlist.dart';
import 'package:in_the_pocket/repository/spotify_repository_base.dart';

class SpotifyPlaylistRepository extends SpotifyRepositoryBase<SpotifyPlaylist> {
  @override
  Future<List<SpotifyPlaylist>> fetch({
    bool Function(SpotifyPlaylist)? filter, 
    String? whereClause,
    String? whereParameter
  }) async {
    List<SpotifyPlaylist> list = await spotifyProvider.getUserPlaylistsAll();

    if (filter != null) {
      list = list.where(filter).toList();
    }

    if (whereClause != null) {
      throw AssertionError('whereClause is not supported by spotify playlist selection.  Use filter instead');
    }

    return list
      ..sort((SpotifyPlaylist a, SpotifyPlaylist b) =>
          a.sortOrder!.compareTo(b.sortOrder!));
  }
}
