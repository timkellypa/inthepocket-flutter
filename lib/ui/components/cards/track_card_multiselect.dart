import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/multiselect_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/selectable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/track_card.dart';

class TrackCardMultiSelect extends TrackCard {
  TrackCardMultiSelect(SetListTrackProxy setListTrack,
      HashMap<String, ItemSelection> selectedItemMap)
      : super(setListTrack, selectedItemMap);

  @override
  State<StatefulWidget> createState() {
    return TrackCardMultiSelectState(setListTrack, selectedItemMap);
  }
}

class TrackCardMultiSelectState extends TrackCardState
    with
        SelectableModelCard<TrackCard, SetListTrackProxy>,
        MultiSelectModelCard<TrackCard, SetListTrackProxy> {
  TrackCardMultiSelectState(SetListTrackProxy setListTrack,
      HashMap<String, ItemSelection> selectedItemMap)
      : super(setListTrack, selectedItemMap);
}
