import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/dismissable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/editable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/selectable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/setlist_card.dart';

class SetlistCardSUD extends SetlistCard {
  SetlistCardSUD(
      Setlist setlist, HashMap<String, ItemSelection> selectedItemMap)
      : super(setlist, selectedItemMap);

  @override
  State<StatefulWidget> createState() {
    return SetlistCardSUDState(setlist, selectedItemMap);
  }
}

class SetlistCardSUDState extends SetlistCardState
    with
        DismissableModelCard<SetlistCard, Setlist>,
        EditableModelCard<SetlistCard, Setlist>,
        SelectableModelCard<SetlistCard, Setlist> {
  SetlistCardSUDState(
      Setlist setlist, HashMap<String, ItemSelection> selectedItemMap)
      : super(setlist, selectedItemMap);
}
