import 'dart:collection';

import 'package:in_the_pocket/bloc/spotify_playlist_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/model/spotify_playlist.dart';

class TrackImportSpotifyTrackArguments {
  TrackImportSpotifyTrackArguments(this.spotifyPlaylistBloc, this.targetSetlist,
      this.spotifyPlaylist, this.itemSelectionMap);
  Setlist? targetSetlist;
  SpotifyPlaylistBloc spotifyPlaylistBloc;
  SpotifyPlaylist? spotifyPlaylist;
  HashMap<String, ItemSelection> itemSelectionMap;
}
