import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/tempo_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/tempo.g.m8.dart';
import 'package:in_the_pocket/ui/components/cards/model_card_state_base.dart';
import 'package:provider/provider.dart';

class TempoCard extends StatefulWidget {
  TempoCard(this.tempo, this.selectedItemMap) : super(key: ObjectKey(tempo));
  final TempoProxy tempo;
  final HashMap<TempoProxy, ItemSelection> selectedItemMap;

  @override
  State<StatefulWidget> createState() {
    return TempoCardState(tempo, selectedItemMap);
  }
}

class TempoCardState extends ModelCardStateBase<TempoCard, TempoProxy> {
  TempoCardState(this._tempo, this._selectedItemMap);

  final TempoProxy _tempo;
  final HashMap<TempoProxy, ItemSelection> _selectedItemMap;

  @override
  HashMap<TempoProxy, ItemSelection> get selectedItemMap => _selectedItemMap;

  @override
  TempoBloc getBloc(BuildContext context) => Provider.of<TempoBloc>(context);

  @override
  TempoProxy get model => _tempo;

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey[200], width: 0),
          borderRadius: BorderRadius.circular(5),
        ),
        color: getColor(),
        child: getListTile(_tempo.displayText));
  }
}
