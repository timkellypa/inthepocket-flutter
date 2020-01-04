import 'dart:collection';

import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';

class EditTrackFormRouteArguments {
  EditTrackFormRouteArguments(
      this.trackBloc, this.setList, this.setListTrack, this.itemSelectionMap);
  SetListProxy setList;
  SetListTrackProxy setListTrack;
  TrackBloc trackBloc;
  HashMap<SetListTrackProxy, ItemSelection> itemSelectionMap;
}
