import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
import 'package:in_the_pocket/bloc/tempo_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/tempo_card.dart';
import 'package:in_the_pocket/ui/components/lists/model_list_base.dart';
import 'package:provider/provider.dart';

class TempoList<CardType extends TempoCard>
    extends ModelListBase<Tempo, CardType> {
  const TempoList(CardType Function(Tempo, HashMap<String, ItemSelection>) creator) : super(creator);
  @override
  String get addItemText => 'No tempos available';

  @override
  ModelBlocBase<Tempo, dynamic> getBloc(BuildContext context) {
    return Provider.of<TempoBloc>(context);
  }
}
