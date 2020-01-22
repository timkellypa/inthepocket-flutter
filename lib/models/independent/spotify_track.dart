import 'package:in_the_pocket/models/independent/sortable_model_base.dart';

class SpotifyTrack implements SortableModelBase {
  @override
  int id;

  @override
  String guid;

  @override
  int sortOrder;

  String spotifyId;

  String spotifyTitle;

  String spotifyAudioFeatures;
}
