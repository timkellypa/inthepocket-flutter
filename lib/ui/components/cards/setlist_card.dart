import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/setlist_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/model_card_state_base.dart';
import 'package:provider/provider.dart';

class SetlistCard extends StatefulWidget {
  SetlistCard(this.setlist, this.selectedItemMap)
      : super(key: ObjectKey(setlist));
  final Setlist setlist;
  final HashMap<String, ItemSelection> selectedItemMap;

  @override
  State<StatefulWidget> createState() {
    return SetlistCardState(setlist, selectedItemMap);
  }
}

class SetlistCardState extends ModelCardStateBase<SetlistCard, Setlist> {
  SetlistCardState(this._setlist, this._selectedItemMap);

  final Setlist _setlist;
  final HashMap<String, ItemSelection> _selectedItemMap;

  @override
  HashMap<String, ItemSelection> get selectedItemMap => _selectedItemMap;

  @override
  SetlistBloc getBloc(BuildContext context) =>
      Provider.of<SetlistBloc>(context, listen: false);

  @override
  Setlist get model => _setlist;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!, width: 0.5),
        borderRadius: BorderRadius.circular(5),
      ),
      color: getColor(),
      child: getListTile(_setlist.description!),
    );
  }
}
