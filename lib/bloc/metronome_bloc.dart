import 'package:audio_service/audio_service.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/services/service_locator.dart';

const String CHANNEL_NAME = 'Metronome';
const String NOTIFICATION_ICON = 'mipmap/ic_launcher';

class MetronomeBloc {
  MetronomeBloc(this.setlist, this.setlistTracks);

  final List<SetlistTrack> setlistTracks;
  final Setlist setlist;

  final AudioHandler _audioHandler = getIt<AudioHandler>();

  void start() {
  }

  void stop() {
    _audioHandler.stop();
  }

  void skipToNext() {
    _audioHandler.skipToNext();
  }

  void skipToPrevious() {
    _audioHandler.skipToPrevious();
  }

  void skipToQueueItem(int trackIndex) {
    _audioHandler.skipToQueueItem(trackIndex);
  }
}
