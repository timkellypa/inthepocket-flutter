import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/selectable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/setlist_card.dart';

class SetlistCardSelect extends SetlistCard {
  SetlistCardSelect(
      Setlist setlist, HashMap<String, ItemSelection> selectedItemMap)
      : super(setlist, selectedItemMap);

  @override
  State<StatefulWidget> createState() {
    return SetlistCardSelectState(setlist, selectedItemMap);
  }
}

class SetlistCardSelectState extends SetlistCardState
    with SelectableModelCard<SetlistCard, Setlist> {
  SetlistCardSelectState(
      Setlist setlist, HashMap<String, ItemSelection> selectedItemMap)
      : super(setlist, selectedItemMap);
}
