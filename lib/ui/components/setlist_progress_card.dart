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

    final Color textColor =
        DefaultTextStyle.of(context).style.color ?? Colors.black;
    final Color mutedTextColor = textColor.withAlpha(155);

    final Color progressColor = Theme.of(context).colorScheme.primary;
    final Color progressRemainingColor = progressColor.withAlpha(80);

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
                            showHoursIfZero: false))
                      ]),
                      Row(spacing: 4, children: <Widget>[
                        Text(timeFormat.format(
                            DateTime.fromMillisecondsSinceEpoch(
                                setlistProgress.estimatedEndTime))),
                        const Icon(Icons.access_time, size: 20),
                      ])
                    ],
                  ),
                if ((setlistProgress.totalDuration ?? 0) > 0)
                  Row(spacing: 4.0, children: <Widget>[
                    Text(formatDuration(
                        setlistProgress.totalDuration! -
                            (setlistProgress.remainingDuration ?? 0),
                        showHoursIfZero: false)),
                    Expanded(
                        child: LinearProgressIndicator(
                      color: progressColor,
                      backgroundColor: progressRemainingColor,
                      value: (setlistProgress.totalDuration! -
                              (setlistProgress.remainingDuration ?? 0)) /
                          setlistProgress.totalDuration!,
                    )),
                    Text(formatDuration(setlistProgress.remainingDuration ?? 0,
                        showHoursIfZero: false)),
                  ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text.rich(TextSpan(
                          style: TextStyle(color: mutedTextColor),
                          text: 'Duration: ',
                          children: <TextSpan>[
                            TextSpan(
                              text: formatDuration(
                                  setlistProgress.currentTrackDuration ?? 0,
                                  showHoursIfZero: false),
                              style: TextStyle(
                                color: textColor, // Adaptive dark/light color
                              ),
                            ),
                            TextSpan(
                                text:
                                    ' / ${formatDuration(setlistProgress.totalDuration ?? 0, showHoursIfZero: false)}')
                          ])),
                      Text.rich(TextSpan(
                          style: TextStyle(color: mutedTextColor),
                          text: 'Track: ',
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  setlistProgress.currentTrackNumber.toString(),
                              style: TextStyle(
                                color: textColor, // Adaptive dark/light color
                              ),
                            ),
                            TextSpan(text: ' / ${setlistProgress.totalTracks}')
                          ])),
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
