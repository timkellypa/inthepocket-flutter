class TimeRange {
  TimeRange({required this.start});

  final int start;
  int? end;

  int get duration {
    if (end == null) {
      return 0;
    }
    return end! - start;
  }
}
