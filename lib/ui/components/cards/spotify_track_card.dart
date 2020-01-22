import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/spotify_track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/spotify_track.dart';
import 'package:in_the_pocket/ui/components/cards/model_card_state_base.dart';
import 'package:provider/provider.dart';

class SpotifyTrackCard extends StatefulWidget {
  SpotifyTrackCard(this.spotifyTrack, this.selectedItemMap)
      : super(key: ObjectKey(spotifyTrack));
  final SpotifyTrack spotifyTrack;
  final HashMap<String, ItemSelection> selectedItemMap;

  @override
  State<StatefulWidget> createState() {
    return SpotifyTrackCardState(spotifyTrack, selectedItemMap);
  }
}

class SpotifyTrackCardState
    extends ModelCardStateBase<SpotifyTrackCard, SpotifyTrack> {
  SpotifyTrackCardState(this._spotifyTrack, this._selectedItemMap);

  final SpotifyTrack _spotifyTrack;
  final HashMap<String, ItemSelection> _selectedItemMap;

  @override
  HashMap<String, ItemSelection> get selectedItemMap => _selectedItemMap;

  @override
  SpotifyTrackBloc getBloc(BuildContext context) =>
      Provider.of<SpotifyTrackBloc>(context);

  @override
  SpotifyTrack get model => _spotifyTrack;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200], width: 0.5),
        borderRadius: BorderRadius.circular(5),
      ),
      color: getColor(),
      child: getListTile(_spotifyTrack.spotifyTitle),
    );
  }
}
