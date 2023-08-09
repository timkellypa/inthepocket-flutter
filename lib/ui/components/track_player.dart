import 'dart:collection';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
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

                            if (playbackStateSnapshot.data!.playing || playbackStateSnapshot.data!.processingState == AudioProcessingState.buffering) {
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
}
