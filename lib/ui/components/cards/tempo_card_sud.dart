import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/tempo.g.m8.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/dismissable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/selectable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/tempo_card.dart';

import 'mixins/editable_model_card.dart';

class TempoCardSUD extends TempoCard {
  TempoCardSUD(TempoProxy tempo, HashMap<String, ItemSelection> selectedItemMap)
      : super(tempo, selectedItemMap);

  @override
  State<StatefulWidget> createState() {
    return TempoCardSUDState(tempo, selectedItemMap);
  }
}

class TempoCardSUDState extends TempoCardState
    with
        DismissableModelCard<TempoCard, TempoProxy>,
        EditableModelCard<TempoCard, TempoProxy>,
        SelectableModelCard<TempoCard, TempoProxy> {
  TempoCardSUDState(
      TempoProxy tempo, HashMap<String, ItemSelection> selectedItemMap)
      : super(tempo, selectedItemMap);
}
