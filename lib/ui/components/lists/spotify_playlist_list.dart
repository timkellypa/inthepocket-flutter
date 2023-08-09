import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
import 'package:in_the_pocket/bloc/spotify_playlist_bloc.dart';
import 'package:in_the_pocket/model/spotify_playlist.dart';
import 'package:in_the_pocket/ui/components/cards/spotify_playlist_card.dart';
import 'package:in_the_pocket/ui/components/lists/model_list_base.dart';
import 'package:provider/provider.dart';

class SpotifyPlaylistList<CardType extends SpotifyPlaylistCard>
    extends ModelListBase<SpotifyPlaylist, CardType> {
  const SpotifyPlaylistList(CardCreator<CardType, SpotifyPlaylist> creator)
      : super(creator);

  @override
  String get addItemText => 'no playlists available.';

  @override
  ModelBlocBase<SpotifyPlaylist, dynamic> getBloc(BuildContext context) {
    return Provider.of<SpotifyPlaylistBloc>(context);
  }
}
