import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/dismissable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/selectable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/tempo_card.dart';

import 'mixins/editable_model_card.dart';

class TempoCardSUD extends TempoCard {
  TempoCardSUD(Tempo tempo, HashMap<String, ItemSelection> selectedItemMap)
      : super(tempo, selectedItemMap);

  @override
  State<StatefulWidget> createState() {
    return TempoCardSUDState(tempo, selectedItemMap);
  }
}

class TempoCardSUDState extends TempoCardState
    with
        DismissableModelCard<TempoCard, Tempo>,
        EditableModelCard<TempoCard, Tempo>,
        SelectableModelCard<TempoCard, Tempo> {
  TempoCardSUDState(
      Tempo tempo, HashMap<String, ItemSelection> selectedItemMap)
      : super(tempo, selectedItemMap);
}
