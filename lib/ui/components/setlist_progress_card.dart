import 'package:flutter/material.dart';
import 'package:in_the_pocket/classes/setlist_progress.dart';
import 'package:in_the_pocket/utilities/date_time_utils.dart';
import 'package:intl/intl.dart';

class SetlistProgressCard extends StatelessWidget {
  const SetlistProgressCard({required this.setlistProgress, Key? key})
      : super(key: key);

  final SetlistProgress setlistProgress;

  @override
  Widget build(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final DateFormat timeFormat = DateFormat.jm(locale);
    if ((setlistProgress.totalDuration ?? 0) > 0) {
      return Card(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                if (setlistProgress.startTime != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(spacing: 4, children: <Widget>[
                        const Icon(Icons.access_time, size: 20),
                        Text(timeFormat.format(
                            DateTime.fromMillisecondsSinceEpoch(
                                setlistProgress.startTime!)))
                      ]),
                      Row(children: <Widget>[
                        const Icon(Icons.timer_outlined, size: 20),
                        Text(formatDuration(setlistProgress.elapsedDuration,
                            showHours: false))
                      ]),
                      Row(spacing: 4, children: <Widget>[
                        Text(timeFormat.format(
                            DateTime.fromMillisecondsSinceEpoch(
                                setlistProgress.estimatedEndTime))),
                        const Icon(Icons.access_time, size: 20),
                      ])
                    ],
                  ),
                if (setlistProgress.startTime != null)
                  Row(spacing: 4.0, children: <Widget>[
                    Text(formatDuration(
                        setlistProgress.totalDuration! -
                            (setlistProgress.remainingDuration ?? 0),
                        showHours: false)),
                    Expanded(
                        child: LinearProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      value: (setlistProgress.totalDuration! -
                              (setlistProgress.remainingDuration ?? 0)) /
                          setlistProgress.totalDuration!,
                    )),
                    Text(formatDuration(setlistProgress.remainingDuration ?? 0,
                        showHours: false)),
                  ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                          'Total Duration: ${formatDuration(setlistProgress.totalDuration!, showHours: false)}'),
                      Text('Total Tracks: ${setlistProgress.totalTracks}')
                    ]),
              ],
            )
            /*
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                  'Setlist Start Time: ${DateTime.fromMillisecondsSinceEpoch(setlistProgress.startTime!).toLocal()}'),
              Text(
                  'Estimated End Time: ${DateTime.fromMillisecondsSinceEpoch(setlistProgress.estimatedEndTime).toLocal()}'),
              Text(
                  'Total Duration: ${formatDuration(setlistProgress.totalDuration ?? 0)}'),
              Text(
                  'Remaining Duration: ${formatDuration(setlistProgress.remainingDuration ?? 0)}'),
              Text(
                  'Elapsed Duration: ${formatDuration(setlistProgress.elapsedDuration)}'),
            ],
          ),
          */
            ),
      );
    } else {
      return Container();
    }
  }
}
