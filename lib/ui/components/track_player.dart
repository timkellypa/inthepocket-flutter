import 'dart:collection';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';
import 'package:in_the_pocket/ui/components/loading.dart';
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

    final TrackBloc trackBloc = Provider.of<TrackBloc>(context);

    trackBloc.connectAudio();
    trackBloc.startAudioService();
  }

  @override
  Widget build(BuildContext context) {
    final TrackBloc trackBloc = Provider.of<TrackBloc>(context);
    return Container(
      child: StreamBuilder<List<SetListTrackProxy>>(
        stream: trackBloc.items,
        builder: (BuildContext context,
            AsyncSnapshot<List<SetListTrackProxy>> tracksSnapshot) {
          // change in list should cause us to restart the track audio service
          if (!tracksSnapshot.hasData) {
            return Center(child: Loading());
          }

          return StreamBuilder<HashMap<String, ItemSelection>>(
            stream: trackBloc.selectedItems,
            initialData: HashMap<String, ItemSelection>(),
            builder: (BuildContext innerContext,
                AsyncSnapshot<HashMap<String, ItemSelection>>
                    selectionsSnapshot) {
              final List<SetListTrackProxy> selectedSetListTracks =
                  trackBloc.getMatchingSelections(SelectionType.selected);
              final SetListTrackProxy selectedSetListTrack =
                  selectedSetListTracks.isNotEmpty
                      ? selectedSetListTracks.first
                      : null;
              if (selectedSetListTrack == null) {
                return Container(width: 0.0, height: 0.0);
              }

              return Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(selectedSetListTrack.track.title,
                        style: const TextStyle(fontSize: 26),
                        overflow: TextOverflow.ellipsis),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          iconSize: 90,
                          icon: Icon(Icons.skip_previous),
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
                            switch (playbackStateSnapshot.data.basicState) {
                              case BasicPlaybackState.buffering:
                              case BasicPlaybackState.playing:
                                toggleIcon = Icon(Icons.pause);
                                break;
                              default:
                                toggleIcon = Icon(Icons.headset);
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
