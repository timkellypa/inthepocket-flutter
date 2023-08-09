import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/dismissable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/selectable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/track_card.dart';

import 'mixins/editable_model_card.dart';

class TrackCardSUD extends TrackCard {
  TrackCardSUD(SetlistTrack setlistTrack,
      HashMap<String, ItemSelection> selectedItemMap)
      : super(setlistTrack, selectedItemMap);

  @override
  State<StatefulWidget> createState() {
    return TrackCardSUDState(setlistTrack, selectedItemMap);
  }
}

class TrackCardSUDState extends TrackCardState
    with
        DismissableModelCard<TrackCard, SetlistTrack>,
        EditableModelCard<TrackCard, SetlistTrack>,
        SelectableModelCard<TrackCard, SetlistTrack> {
  TrackCardSUDState(SetlistTrack setlistTrack,
      HashMap<String, ItemSelection> selectedItemMap)
      : super(setlistTrack, selectedItemMap);
}
