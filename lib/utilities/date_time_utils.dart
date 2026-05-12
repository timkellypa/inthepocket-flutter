String formatDuration(int duration, {bool showHours = true}) {
  int minutes = duration ~/ 60000;
  final int seconds = (duration % 60000) ~/ 1000;
  if (showHours) {
    final int hours = minutes ~/ 60;
    minutes = minutes % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  } else {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
