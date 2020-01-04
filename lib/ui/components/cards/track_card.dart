import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';
import 'package:in_the_pocket/ui/components/cards/model_card_state_base.dart';
import 'package:provider/provider.dart';

class TrackCard extends StatefulWidget {
  TrackCard(this.setListTrack, this.selectedItemMap)
      : super(key: ObjectKey(setListTrack));
  final SetListTrackProxy setListTrack;
  final HashMap<SetListTrackProxy, ItemSelection> selectedItemMap;

  @override
  State<StatefulWidget> createState() {
    return TrackCardState(setListTrack, selectedItemMap);
  }
}

class TrackCardState extends ModelCardStateBase<TrackCard, SetListTrackProxy> {
  TrackCardState(this._setListTrack, this._selectedItemMap);

  final SetListTrackProxy _setListTrack;
  final HashMap<SetListTrackProxy, ItemSelection> _selectedItemMap;

  @override
  HashMap<SetListTrackProxy, ItemSelection> get selectedItemMap =>
      _selectedItemMap;

  @override
  TrackBloc getBloc(BuildContext context) => Provider.of<TrackBloc>(context);

  @override
  SetListTrackProxy get model => _setListTrack;

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey[200], width: 0),
          borderRadius: BorderRadius.circular(5),
        ),
        color: getColor(),
        child: getListTile(_setListTrack.track.title));
  }
}
