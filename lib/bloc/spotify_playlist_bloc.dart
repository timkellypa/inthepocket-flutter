import 'dart:async';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/model/spotify_playlist.dart';
import 'package:in_the_pocket/repository/spotify_playlist_repository.dart';

import 'model_bloc_base.dart';

class SpotifyPlaylistBloc
    extends ModelBlocBase<SpotifyPlaylist, SpotifyPlaylistRepository> {
  SpotifyPlaylistBloc({this.importTargetSetlist}) : super();

  final Setlist? importTargetSetlist;

  bool firstFetch = true;

  @override
  SpotifyPlaylistRepository get repository {
    return SpotifyPlaylistRepository();
  }

  @override
  String get listTitle {
    return 'Spotify Playlists';
  }

  @override
  Future<void> insert(SpotifyPlaylist item) async {
    await repository.insert(item);
  }

  @override
  Future<void> update(SpotifyPlaylist item) async {
    await repository.update(item);
  }

  @override
  Future<void> delete(SpotifyPlaylist item) async {
    await repository.delete(item.id!);
  }
}
