import 'package:in_the_pocket/classes/time_range.dart';

class SetlistProgress {
  int? totalTracks;
  int? currentTrackIndex;
  int? totalDuration;
  int? remainingDuration;
  int? currentTrackDuration;
  bool remainingTracksWithoutDurationExist = false;

  int? startTime;
  final List<TimeRange> pauseTimes = <TimeRange>[];

  int get estimatedEndTime {
    return DateTime.now().millisecondsSinceEpoch + (remainingDuration ?? 0);
  }

  bool get isPaused {
    return pauseTimes.isNotEmpty && pauseTimes.last.end == null;
  }

  int get currentTrackNumber {
    return (currentTrackIndex ?? 0) + 1;
  }

  int get elapsedDuration {
    int calculatedEnd = DateTime.now().millisecondsSinceEpoch;
    if (pauseTimes.isNotEmpty && pauseTimes.last.end == null) {
      calculatedEnd = pauseTimes.last.start;
    }
    int elapsed = calculatedEnd - (startTime ?? 0);
    for (final TimeRange pause in pauseTimes) {
      elapsed -= pause.duration;
    }
    return elapsed;
  }
}
