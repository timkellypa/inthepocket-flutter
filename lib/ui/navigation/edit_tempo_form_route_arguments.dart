import 'dart:collection';

import 'package:in_the_pocket/bloc/tempo_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/model/setlistdb.dart';

class EditTempoFormRouteArguments {
  EditTempoFormRouteArguments(
      this.tempoBloc, this.tempo, this.itemSelectionMap);
  TempoBloc tempoBloc;
  Tempo? tempo;
  HashMap<String, ItemSelection> itemSelectionMap;
}
