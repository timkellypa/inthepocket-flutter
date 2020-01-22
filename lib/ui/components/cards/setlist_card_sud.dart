import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/dismissable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/editable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/selectable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/setlist_card.dart';

class SetListCardSUD extends SetListCard {
  SetListCardSUD(
      SetListProxy setList, HashMap<String, ItemSelection> selectedItemMap)
      : super(setList, selectedItemMap);

  @override
  State<StatefulWidget> createState() {
    return SetListCardSUDState(setList, selectedItemMap);
  }
}

class SetListCardSUDState extends SetListCardState
    with
        DismissableModelCard<SetListCard, SetListProxy>,
        EditableModelCard<SetListCard, SetListProxy>,
        SelectableModelCard<SetListCard, SetListProxy> {
  SetListCardSUDState(
      SetListProxy setList, HashMap<String, ItemSelection> selectedItemMap)
      : super(setList, selectedItemMap);
}
