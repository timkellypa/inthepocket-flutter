import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/model/setlistdb.dart';

class TrackImportSpotifyPlaylistArguments {
  TrackImportSpotifyPlaylistArguments(this.trackBloc, this.setlist);
  Setlist? setlist;
  TrackBloc trackBloc;
}
