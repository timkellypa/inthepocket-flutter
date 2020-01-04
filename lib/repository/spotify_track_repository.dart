import 'package:in_the_pocket/models/independent/spotify_playlist.dart';
import 'package:in_the_pocket/models/independent/spotify_track.dart';
import 'package:in_the_pocket/repository/spotify_repository_base.dart';

class SpotifyTrackRepository extends SpotifyRepositoryBase<SpotifyTrack> {
  SpotifyTrackRepository({this.spotifyPlaylist});
  final SpotifyPlaylist spotifyPlaylist;
  @override
  Future<List<SpotifyTrack>> fetch({Function filter}) async {
    List<SpotifyTrack> list = <SpotifyTrack>[];
    if (spotifyPlaylist != null) {
      list = await spotifyProvider.getPlaylistTracksAll(spotifyPlaylist);
    }

    if (filter != null) {
      list = list.where(filter).toList();
    }

    return list
      ..sort((SpotifyTrack a, SpotifyTrack b) =>
          a.sortOrder.compareTo(b.sortOrder));
  }
}
