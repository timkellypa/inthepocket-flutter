import 'dart:collection';

import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/model/setlistdb.dart';

class EditTrackFormRouteArguments {
  EditTrackFormRouteArguments(
      this.trackBloc, this.setlist, this.setlistTrack, this.itemSelectionMap);
  Setlist? setlist;
  SetlistTrack? setlistTrack;
  TrackBloc trackBloc;
  HashMap<String, ItemSelection> itemSelectionMap;
}
