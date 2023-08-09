import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/multiselect_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/selectable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/track_card.dart';

class TrackCardMultiSelect extends TrackCard {
  TrackCardMultiSelect(SetlistTrack setlistTrack,
      HashMap<String, ItemSelection> selectedItemMap)
      : super(setlistTrack, selectedItemMap);

  @override
  State<StatefulWidget> createState() {
    return TrackCardMultiSelectState(setlistTrack, selectedItemMap);
  }
}

class TrackCardMultiSelectState extends TrackCardState
    with
        SelectableModelCard<TrackCard, SetlistTrack>,
        MultiSelectModelCard<TrackCard, SetlistTrack> {
  TrackCardMultiSelectState(SetlistTrack setlistTrack,
      HashMap<String, ItemSelection> selectedItemMap)
      : super(setlistTrack, selectedItemMap);
}
