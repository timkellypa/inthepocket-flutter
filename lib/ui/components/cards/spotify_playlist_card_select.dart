import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/spotify_playlist.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/selectable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/spotify_playlist_card.dart';

class SpotifyPlaylistCardSelect extends SpotifyPlaylistCard {
  SpotifyPlaylistCardSelect(SpotifyPlaylist spotifyPlaylist,
      HashMap<SpotifyPlaylist, ItemSelection> selectedItemMap)
      : super(spotifyPlaylist, selectedItemMap);

  @override
  State<StatefulWidget> createState() {
    return SpotifyPlaylistCardSelectState(spotifyPlaylist, selectedItemMap);
  }
}

class SpotifyPlaylistCardSelectState extends SpotifyPlaylistCardState
    with SelectableModelCard<SpotifyPlaylistCard, SpotifyPlaylist> {
  SpotifyPlaylistCardSelectState(SpotifyPlaylist spotifyPlaylist,
      HashMap<SpotifyPlaylist, ItemSelection> selectedItemMap)
      : super(spotifyPlaylist, selectedItemMap);
}
