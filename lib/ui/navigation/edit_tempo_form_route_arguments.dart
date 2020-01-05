import 'dart:collection';

import 'package:in_the_pocket/bloc/tempo_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/tempo.g.m8.dart';

class EditTempoFormRouteArguments {
  EditTempoFormRouteArguments(
      this.tempoBloc, this.tempo, this.itemSelectionMap);
  TempoBloc tempoBloc;
  TempoProxy tempo;
  HashMap<TempoProxy, ItemSelection> itemSelectionMap;
}
