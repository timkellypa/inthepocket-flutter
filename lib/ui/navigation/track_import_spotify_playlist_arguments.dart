import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';

class TrackImportSpotifyPlaylistArguments {
  TrackImportSpotifyPlaylistArguments(this.trackBloc, this.setList);
  SetListProxy setList;
  TrackBloc trackBloc;
}
