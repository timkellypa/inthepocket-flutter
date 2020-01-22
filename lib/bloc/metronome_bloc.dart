import 'package:audio_service/audio_service.dart';
import 'package:in_the_pocket/audio/track_list_player_task.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';

const String CHANNEL_NAME = 'Metronome';
const String NOTIFICATION_ICON = 'mipmap/ic_launcher';

class MetronomeBloc {
  MetronomeBloc(this.setList, this.setListTracks);

  final List<SetListTrackProxy> setListTracks;
  final SetListProxy setList;

  void connect() {
    AudioService.connect();
  }

  Future<void> _trackListPlayerTaskEntrypoint() async {
    AudioServiceBackground.run(() => TrackListPlayerTask());
  }

  void start() {
    AudioService.start(
      backgroundTaskEntrypoint: _trackListPlayerTaskEntrypoint,
      enableQueue: true,
      resumeOnClick: true,
      androidNotificationChannelName: CHANNEL_NAME,
      androidNotificationIcon: NOTIFICATION_ICON,
    );
  }

  void stop() {
    AudioService.stop();
  }

  void skipToNext() {
    AudioService.skipToNext();
  }

  void skipToPrevious() {
    AudioService.skipToPrevious();
  }

  void skipToQueueItem(String trackPath) {
    AudioService.skipToQueueItem(trackPath);
  }
}
