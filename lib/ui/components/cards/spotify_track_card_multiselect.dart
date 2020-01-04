import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/spotify_track.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/multiselect_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/mixins/selectable_model_card.dart';
import 'package:in_the_pocket/ui/components/cards/spotify_track_card.dart';

class SpotifyTrackCardMultiSelect extends SpotifyTrackCard {
  SpotifyTrackCardMultiSelect(SpotifyTrack spotifyTrack,
      HashMap<SpotifyTrack, ItemSelection> selectedItemMap)
      : super(spotifyTrack, selectedItemMap);

  @override
  State<StatefulWidget> createState() {
    return SpotifyTrackCardMultiSelectState(spotifyTrack, selectedItemMap);
  }
}

class SpotifyTrackCardMultiSelectState extends SpotifyTrackCardState
    with
        SelectableModelCard<SpotifyTrackCard, SpotifyTrack>,
        MultiSelectModelCard<SpotifyTrackCard, SpotifyTrack> {
  SpotifyTrackCardMultiSelectState(SpotifyTrack spotifyTrack,
      HashMap<SpotifyTrack, ItemSelection> selectedItemMap)
      : super(spotifyTrack, selectedItemMap);
}
