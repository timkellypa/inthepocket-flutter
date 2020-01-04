import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/selectable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/setlist_card.dart';

class SetListCardSelect extends SetListCard {
  SetListCardSelect(SetListProxy setList,
      HashMap<SetListProxy, ItemSelection> selectedItemMap)
      : super(setList, selectedItemMap);

  @override
  State<StatefulWidget> createState() {
    return SetListCardSelectState(setList, selectedItemMap);
  }
}

class SetListCardSelectState extends SetListCardState
    with SelectableModelCard<SetListCard, SetListProxy> {
  SetListCardSelectState(SetListProxy setList,
      HashMap<SetListProxy, ItemSelection> selectedItemMap)
      : super(setList, selectedItemMap);
}
