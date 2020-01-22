import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/spotify_playlist_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/spotify_playlist.dart';
import 'package:in_the_pocket/ui/components/cards/model_card_state_base.dart';
import 'package:provider/provider.dart';

class SpotifyPlaylistCard extends StatefulWidget {
  SpotifyPlaylistCard(this.spotifyPlaylist, this.selectedItemMap)
      : super(key: ObjectKey(spotifyPlaylist));
  final SpotifyPlaylist spotifyPlaylist;
  final HashMap<String, ItemSelection> selectedItemMap;

  @override
  State<StatefulWidget> createState() {
    return SpotifyPlaylistCardState(spotifyPlaylist, selectedItemMap);
  }
}

class SpotifyPlaylistCardState
    extends ModelCardStateBase<SpotifyPlaylistCard, SpotifyPlaylist> {
  SpotifyPlaylistCardState(this._spotifyPlaylist, this._selectedItemMap);

  final SpotifyPlaylist _spotifyPlaylist;
  final HashMap<String, ItemSelection> _selectedItemMap;

  @override
  HashMap<String, ItemSelection> get selectedItemMap => _selectedItemMap;

  @override
  SpotifyPlaylistBloc getBloc(BuildContext context) =>
      Provider.of<SpotifyPlaylistBloc>(context);

  @override
  SpotifyPlaylist get model => _spotifyPlaylist;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200], width: 0.5),
        borderRadius: BorderRadius.circular(5),
      ),
      color: getColor(),
      child: getListTile(_spotifyPlaylist.spotifyTitle),
    );
  }
}
