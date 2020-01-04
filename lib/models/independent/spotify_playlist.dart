import 'package:in_the_pocket/models/independent/model_base.dart';

class SpotifyPlaylist implements ModelBase {
  @override
  int id;

  @override
  int sortOrder;

  String spotifyId;

  String spotifyTitle;
}
