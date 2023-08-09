import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/model_card_state_base.dart';
import 'package:provider/provider.dart';

class TrackCard extends StatefulWidget {
  TrackCard(this.setlistTrack, this.selectedItemMap)
      : super(key: ObjectKey(setlistTrack));
  final SetlistTrack setlistTrack;
  final HashMap<String, ItemSelection> selectedItemMap;

  @override
  State<StatefulWidget> createState() {
    return TrackCardState(setlistTrack, selectedItemMap);
  }
}

class TrackCardState extends ModelCardStateBase<TrackCard, SetlistTrack> {
  TrackCardState(this._setlistTrack, this._selectedItemMap);

  final SetlistTrack _setlistTrack;
  final HashMap<String, ItemSelection> _selectedItemMap;

  @override
  HashMap<String, ItemSelection> get selectedItemMap => _selectedItemMap;

  @override
  TrackBloc getBloc(BuildContext context) => Provider.of<TrackBloc>(context, listen: false);

  @override
  SetlistTrack get model => _setlistTrack;

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey[200]!, width: 0),
          borderRadius: BorderRadius.circular(5),
        ),
        color: getColor(),
        child: getListTile(_setlistTrack.plTrack!.title!));
  }
}
