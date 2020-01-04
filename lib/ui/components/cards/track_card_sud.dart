import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/dismissable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/selectable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/track_card.dart';

import 'mixins/editable_model_card.dart';

class TrackCardSUD extends TrackCard {
  TrackCardSUD(SetListTrackProxy setListTrack,
      HashMap<SetListTrackProxy, ItemSelection> selectedItemMap)
      : super(setListTrack, selectedItemMap);

  @override
  State<StatefulWidget> createState() {
    return TrackCardSUDState(setListTrack, selectedItemMap);
  }
}

class TrackCardSUDState extends TrackCardState
    with
        DismissableModelCard<TrackCard, SetListTrackProxy>,
        EditableModelCard<TrackCard, SetListTrackProxy>,
        SelectableModelCard<TrackCard, SetListTrackProxy> {
  TrackCardSUDState(SetListTrackProxy setListTrack,
      HashMap<SetListTrackProxy, ItemSelection> selectedItemMap)
      : super(setListTrack, selectedItemMap);
}
