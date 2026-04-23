import 'dart:collection';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/click_info.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/click_state_display.dart';
import 'package:in_the_pocket/ui/haptics/MetronomeBuzzer.dart';
import 'package:provider/provider.dart';

class TrackPlayer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TrackPlayerState();
  }
}

class TrackPlayerState extends State<TrackPlayer> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  MetronomeBuzzer? buzzer;

  @override
  Widget build(BuildContext context) {
    final TrackBloc trackBloc = Provider.of<TrackBloc>(context);

    return Container(
      child: StreamBuilder<List<SetlistTrack>>(
        stream: trackBloc.items,
        builder: (BuildContext context,
            AsyncSnapshot<List<SetlistTrack>> tracksSnapshot) {
          // change in list should cause us to restart the track audio service
          if (!tracksSnapshot.hasData) {
            return Container();
          }

          return StreamBuilder<HashMap<String, ItemSelection>>(
            stream: trackBloc.selectedItems,
            initialData: HashMap<String, ItemSelection>(),
            builder: (BuildContext innerContext,
                AsyncSnapshot<HashMap<String, ItemSelection>>
                    selectionsSnapshot) {
              final List<SetlistTrack?> selectedSetlistTracks =
                  trackBloc.getMatchingSelections(SelectionType.selected);
              final SetlistTrack? selectedSetlistTrack =
                  selectedSetlistTracks.isNotEmpty
                      ? selectedSetlistTracks.first
                      : null;
              if (selectedSetlistTrack == null) {
                return Container(width: 0.0, height: 0.0);
              }

              return Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(selectedSetlistTrack.plTrack!.title!,
                        style: const TextStyle(fontSize: 26),
                        overflow: TextOverflow.ellipsis),
                    if (selectedSetlistTrack.plTrack!.artist != null &&
                        selectedSetlistTrack.plTrack!.artist!.isNotEmpty)
                      Text(selectedSetlistTrack.plTrack!.artist ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontStyle: FontStyle.italic),
                          overflow: TextOverflow.ellipsis),
                    if (selectedSetlistTrack.notes != null &&
                        selectedSetlistTrack.notes!.isNotEmpty)
                      Text(selectedSetlistTrack.notes ?? '',
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis),
                    if (selectedSetlistTrack.plTrack!.plTempos?.isNotEmpty ??
                        false)
                      StreamBuilder<ClickState>(
                          stream: trackBloc.indicatorStateBloc.clickStateStream,
                          initialData: ClickState(count: 0),
                          builder: (BuildContext context,
                              AsyncSnapshot<ClickState> clickState) {
                            return ClickStateDisplay(
                                clickState: clickState.data!);
                          })
                    else
                      Center(
                          child: TextButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Add tempos to enable click track'),
                        onPressed: () {
                          trackBloc.selectItem(
                              selectedSetlistTrack, SelectionType.editing);
                        },
                      )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          iconSize: 90,
                          icon: const Icon(Icons.skip_previous),
                          onPressed: trackBloc.isFirstSelected
                              ? null
                              : () {
                                  trackBloc.skipToPrevious();
                                },
                        ),
                        StreamBuilder<PlaybackState>(
                          stream: trackBloc.audioPlaybackStream,
                          initialData: trackBloc.audioPlaybackState,
                          builder: (BuildContext context,
                              AsyncSnapshot<PlaybackState>
                                  playbackStateSnapshot) {
                            Icon toggleIcon;

                            if (playbackStateSnapshot.data!.playing ||
                                playbackStateSnapshot.data!.processingState ==
                                    AudioProcessingState.buffering) {
                              toggleIcon = const Icon(Icons.pause);
                            } else {
                              toggleIcon = const Icon(Icons.headset);
                            }

                            bool disabled = false;
                            if (selectedSetlistTrack.plTrack!.plTempos ==
                                    null ||
                                selectedSetlistTrack
                                    .plTrack!.plTempos!.isEmpty) {
                              disabled = true;
                            }

                            return IconButton(
                                iconSize: 90,
                                icon: toggleIcon,
                                onPressed: disabled
                                    ? null
                                    : () {
                                        trackBloc.audioClick();
                                      });
                          },
                        ),
                        IconButton(
                          iconSize: 90,
                          icon: const Icon(Icons.skip_next),
                          onPressed: trackBloc.isLastSelected
                              ? null
                              : () {
                                  trackBloc.skipToNext();
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
