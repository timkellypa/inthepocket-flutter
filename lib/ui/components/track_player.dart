import 'dart:collection';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/metronome_indicator_state_bloc.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/haptics/MetronomeBuzzer.dart';
import 'package:led_bulb_indicator/led_bulb_indicator.dart';
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

    buzzer?.stopListening();
    buzzer = MetronomeBuzzer(bloc: trackBloc.indicatorStateBloc);
    buzzer!.listen();

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
                    Text(selectedSetlistTrack.notes ?? '',
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis),
                    StreamBuilder<ClickState>(
                        stream: trackBloc.indicatorStateBloc.clickStateStream,
                        initialData: ClickState(count: 0),
                        builder: (BuildContext context,
                            AsyncSnapshot<ClickState> clickState) {
                          const LedBulbColors inactiveColor = LedBulbColors.off,
                              accentColor = LedBulbColors.green,
                              clickColor = LedBulbColors.red;
                          const double size = 30;
                          final ClickState state = clickState.data!;
                          final List<Widget> indicators =
                              List<Widget>.empty(growable: true);

                          for (int i = 1; i <= state.beatsPerBar; ++i) {
                            LedBulbColors color = inactiveColor;
                            bool glow = false;
                            if (i == state.count) {
                              glow = true;
                              if (state.accent) {
                                color = accentColor;
                              } else {
                                color = clickColor;
                              }
                            }
                            indicators.add(LedBulbIndicator(
                                size: size, initialState: color, glow: glow));
                          }

                          return Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  key: const Key('ClickIndicatorRow'),
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: indicators));
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          iconSize: 90,
                          icon: const Icon(Icons.skip_previous),
                          onPressed: () {
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

                            return IconButton(
                              iconSize: 90,
                              icon: toggleIcon,
                              onPressed: () {
                                trackBloc.audioClick();
                              },
                            );
                          },
                        ),
                        IconButton(
                          iconSize: 90,
                          icon: const Icon(Icons.skip_next),
                          onPressed: () {
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
    buzzer?.stopListening();
  }
}
