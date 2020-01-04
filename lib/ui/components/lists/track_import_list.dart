import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/ui/components/cards/track_card.dart';
import 'package:in_the_pocket/ui/components/lists/track_list.dart';
import 'package:provider/provider.dart';

class TrackImportList<TrackCardType extends TrackCard>
    extends TrackList<TrackCardType> {
  const TrackImportList(Function creator) : super(creator);

  @override
  ModelBlocBase<dynamic, dynamic> getBloc(BuildContext context) {
    return Provider.of<TrackBloc>(context);
  }

  @override
  String get addItemText => 'No Tracks available for this setlist';
}
