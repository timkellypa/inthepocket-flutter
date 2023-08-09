import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/track_card.dart';
import 'package:in_the_pocket/ui/components/lists/model_list_base.dart';
import 'package:provider/provider.dart';

class TrackList<TrackCardType extends TrackCard>
    extends ModelListBase<SetlistTrack, TrackCardType> {
  const TrackList(TrackCardType Function(SetlistTrack, HashMap<String, ItemSelection>) creator) : super(creator);
  @override
  String get addItemText => 'Start Adding Tracks...';

  @override
  ModelBlocBase<SetlistTrack, dynamic> getBloc(BuildContext context) {
    return Provider.of<TrackBloc>(context);
  }
}
