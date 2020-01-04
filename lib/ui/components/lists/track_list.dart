import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';
import 'package:in_the_pocket/ui/components/lists/model_list_base.dart';
import 'package:in_the_pocket/ui/components/cards/track_card.dart';
import 'package:provider/provider.dart';

class TrackList<TrackCardType extends TrackCard>
    extends ModelListBase<SetListTrackProxy, TrackCardType> {
  const TrackList(Function creator) : super(creator);
  @override
  String get addItemText => 'Start Adding Tracks...';

  @override
  ModelBlocBase<dynamic, dynamic> getBloc(BuildContext context) {
    return Provider.of<TrackBloc>(context);
  }
}
