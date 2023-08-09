import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/tempo_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/repository/tempo_repository.dart';
import 'package:in_the_pocket/ui/components/cards/model_card_state_base.dart';
import 'package:provider/provider.dart';

class TempoCard extends StatefulWidget {
  TempoCard(this.tempo, this.selectedItemMap) : super(key: ObjectKey(tempo));
  final Tempo tempo;
  final HashMap<String, ItemSelection> selectedItemMap;

  @override
  State<StatefulWidget> createState() {
    return TempoCardState(tempo, selectedItemMap);
  }
}

class TempoCardState extends ModelCardStateBase<TempoCard, Tempo> {
  TempoCardState(this._tempo, this._selectedItemMap);

  final Tempo _tempo;
  final HashMap<String, ItemSelection> _selectedItemMap;

  @override
  HashMap<String, ItemSelection> get selectedItemMap => _selectedItemMap;

  @override
  TempoBloc getBloc(BuildContext context) => Provider.of<TempoBloc>(context, listen: false);

  @override
  Tempo get model => _tempo;

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey[200]!, width: 0),
          borderRadius: BorderRadius.circular(5),
        ),
        color: getColor(),
        child: getListTile(TempoRepository().getTempoDisplayText(_tempo))
    );
  }
}
