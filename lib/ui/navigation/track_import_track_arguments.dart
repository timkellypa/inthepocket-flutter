import 'dart:collection';

import 'package:in_the_pocket/bloc/setlist_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/model/setlistdb.dart';

class TrackImportTrackArguments {
  TrackImportTrackArguments(this.setlistBloc, this.targetSetlist, this.setlist,
      this.itemSelectionMap);

  Setlist targetSetlist;
  Setlist? setlist;
  SetlistBloc setlistBloc;
  HashMap<String, ItemSelection> itemSelectionMap;
}
