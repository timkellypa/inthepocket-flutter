import 'dart:collection';

import 'package:in_the_pocket/bloc/spotify_playlist_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/models/independent/spotify_playlist.dart';

class TrackImportSpotifyTrackArguments {
  TrackImportSpotifyTrackArguments(this.spotifyPlaylistBloc, this.targetSetList,
      this.spotifyPlaylist, this.itemSelectionMap);
  SetListProxy targetSetList;
  SpotifyPlaylistBloc spotifyPlaylistBloc;
  SpotifyPlaylist spotifyPlaylist;
  HashMap<SpotifyPlaylist, ItemSelection> itemSelectionMap;
}
