import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
import 'package:in_the_pocket/bloc/spotify_track_bloc.dart';
import 'package:in_the_pocket/model/spotify_track.dart';
import 'package:in_the_pocket/ui/components/cards/spotify_track_card.dart';
import 'package:in_the_pocket/ui/components/lists/model_list_base.dart';
import 'package:provider/provider.dart';

class SpotifyTrackList<CardType extends SpotifyTrackCard>
    extends ModelListBase<SpotifyTrack, CardType> {
  const SpotifyTrackList(CardCreator<CardType, SpotifyTrack> creator)
      : super(creator);

  @override
  String get addItemText => 'no tracks available.';

  @override
  ModelBlocBase<SpotifyTrack, dynamic> getBloc(BuildContext context) {
    return Provider.of<SpotifyTrackBloc>(context);
  }
}
