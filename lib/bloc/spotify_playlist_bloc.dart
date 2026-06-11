import 'dart:async';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/model/spotify_playlist.dart';
import 'package:in_the_pocket/repository/spotify_playlist_repository.dart';

import 'model_bloc_base.dart';

class SpotifyPlaylistBloc
    extends ModelBlocBase<SpotifyPlaylist, SpotifyPlaylistRepository> {
  SpotifyPlaylistBloc({this.importTargetSetlist}) : super();

  final Setlist? importTargetSetlist;

  @override
  Future<SpotifyPlaylist> buildNewItem() async {
    throw UnsupportedError(
        'SpotifyPlaylistBloc does not support building new items');
  }

  @override
  SpotifyPlaylistRepository get repository {
    return SpotifyPlaylistRepository();
  }

  @override
  String get listTitle {
    return 'Spotify Playlists';
  }

  @override
  Future<void> upsert(SpotifyPlaylist item) async {
    await repository.upsert(item);
  }

  @override
  Future<void> delete(SpotifyPlaylist item) async {
    await repository.delete(item.id!);
  }
}
