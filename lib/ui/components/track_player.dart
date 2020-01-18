import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';
import 'package:provider/provider.dart';

class TrackPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TrackBloc trackBloc = Provider.of<TrackBloc>(context);
    return Container(
      child: StreamBuilder<List<SetListTrackProxy>>(
        stream: trackBloc.items,
        builder: (BuildContext context,
            AsyncSnapshot<List<SetListTrackProxy>> tracksSnapshot) {
          return StreamBuilder<HashMap<SetListTrackProxy, ItemSelection>>(
              stream: trackBloc.selectedItems,
              initialData: HashMap<SetListTrackProxy, ItemSelection>(),
              builder: (BuildContext innerContext,
                  AsyncSnapshot<HashMap<SetListTrackProxy, ItemSelection>>
                      selectionsSnapshot) {
                List<SetListTrackProxy> setListTracks;
                if (tracksSnapshot.hasData) {
                  setListTracks = tracksSnapshot.data;
                } else if (tracksSnapshot.hasError) {
                  return Text('ERROR: ${tracksSnapshot.error}');
                } else {
                  setListTracks = <SetListTrackProxy>[];
                }

                SetListTrackProxy selectedSetListTrack;
                if (selectionsSnapshot.hasData) {
                  selectionsSnapshot.data.forEach(
                      (SetListTrackProxy setListTrack,
                          ItemSelection selection) {
                    if (selection.selectionType & SelectionType.selected > 0) {
                      selectedSetListTrack = setListTrack;
                    }
                  });
                }
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
                              trackBloc.changeTrack(selectionsSnapshot.data,
                                  setListTracks, TrackDirection.previous);
                            },
                          ),
                          IconButton(
                            iconSize: 90,
                            icon: const Icon(FontAwesomeIcons.headphones),
                            onPressed: () {},
                          ),
                          IconButton(
                              iconSize: 90,
                              icon: const Icon(Icons.skip_next),
                              onPressed: () {
                                trackBloc.changeTrack(selectionsSnapshot.data,
                                    setListTracks, TrackDirection.next);
                              }),
                        ],
                      )
                    ],
                  ),
                );
              });
        },
      ),
    );
  }
}
