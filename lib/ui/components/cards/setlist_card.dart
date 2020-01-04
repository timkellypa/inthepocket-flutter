import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/setlist_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/ui/components/cards/model_card_state_base.dart';
import 'package:provider/provider.dart';

class SetListCard extends StatefulWidget {
  SetListCard(this.setList, this.selectedItemMap)
      : super(key: ObjectKey(setList));
  final SetListProxy setList;
  final HashMap<SetListProxy, ItemSelection> selectedItemMap;

  @override
  State<StatefulWidget> createState() {
    return SetListCardState(setList, selectedItemMap);
  }
}

class SetListCardState extends ModelCardStateBase<SetListCard, SetListProxy> {
  SetListCardState(this._setList, this._selectedItemMap);

  final SetListProxy _setList;
  final HashMap<SetListProxy, ItemSelection> _selectedItemMap;

  @override
  HashMap<SetListProxy, ItemSelection> get selectedItemMap => _selectedItemMap;

  @override
  SetListBloc getBloc(BuildContext context) =>
      Provider.of<SetListBloc>(context);

  @override
  SetListProxy get model => _setList;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200], width: 0.5),
        borderRadius: BorderRadius.circular(5),
      ),
      color: getColor(),
      child: getListTile(_setList.description),
    );
  }
}
