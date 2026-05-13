String formatDuration(int duration, {bool showHoursIfZero = true}) {
  int minutes = (duration ~/ 60000) % 60;
  final int seconds = (duration % 60000) ~/ 1000;
  final int hours = minutes ~/ 60;

  if (showHoursIfZero || hours > 0) {
    final int hours = minutes ~/ 60;
    minutes = minutes % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  } else {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
