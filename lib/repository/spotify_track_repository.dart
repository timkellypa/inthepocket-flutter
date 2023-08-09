import 'package:in_the_pocket/model/spotify_playlist.dart';
import 'package:in_the_pocket/model/spotify_track.dart';
import 'package:in_the_pocket/repository/spotify_repository_base.dart';

class SpotifyTrackRepository extends SpotifyRepositoryBase<SpotifyTrack> {
  SpotifyTrackRepository({required this.spotifyPlaylist});
  final SpotifyPlaylist? spotifyPlaylist;
  @override
  Future<List<SpotifyTrack>> fetch({
    bool Function(SpotifyTrack)? filter, 
    String? whereClause,
    String? whereParameter
  }) async {
    List<SpotifyTrack> list = <SpotifyTrack>[];
    if (spotifyPlaylist == null) {
      return list;
    }

    list = await spotifyProvider.getPlaylistTracksAll(spotifyPlaylist!);

    if (filter != null) {
      list = list.where(filter).toList();
    }

    if (whereClause != null) {
      throw AssertionError('whereClause is not supported by spotify playlist selection.  Use filter instead');
    }

    return list
      ..sort((SpotifyTrack a, SpotifyTrack b) =>
          a.sortOrder!.compareTo(b.sortOrder!));
  }
}
