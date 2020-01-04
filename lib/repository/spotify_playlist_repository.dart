import 'package:in_the_pocket/models/independent/spotify_playlist.dart';
import 'package:in_the_pocket/repository/spotify_repository_base.dart';

class SpotifyPlaylistRepository extends SpotifyRepositoryBase<SpotifyPlaylist> {
  @override
  Future<List<SpotifyPlaylist>> fetch({Function filter}) async {
    List<SpotifyPlaylist> list = await spotifyProvider.getUserPlaylistsAll();

    if (filter != null) {
      list = list.where(filter).toList();
    }
    return list
      ..sort((SpotifyPlaylist a, SpotifyPlaylist b) =>
          a.sortOrder.compareTo(b.sortOrder));
  }
}
