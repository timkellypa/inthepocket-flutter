import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/spotify_track_bloc.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/models/independent/spotify_playlist.dart';
import 'package:in_the_pocket/models/independent/spotify_track.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../components/cards/spotify_track_card_multiselect.dart';
import '../components/common_bottom_bar.dart';
import '../components/lists/spotify_track_list.dart';
import '../navigation/application_router.dart';

class TrackImportSpotifyTrackPage extends StatefulWidget {
  const TrackImportSpotifyTrackPage(this._targetSetList,
      {Key key, this.spotifyPlaylist})
      : super(key: key);

  final SetListProxy _targetSetList;
  final SpotifyPlaylist spotifyPlaylist;

  @override
  State<StatefulWidget> createState() {
    return TrackImportSpotifyTrackPageState(_targetSetList, spotifyPlaylist);
  }
}

class TrackImportSpotifyTrackPageState
    extends State<TrackImportSpotifyTrackPage> {
  TrackImportSpotifyTrackPageState(this._targetSetList, this.spotifyPlaylist);

  final SetListProxy _targetSetList;
  final SpotifyPlaylist spotifyPlaylist;

  TrackBloc trackBloc;
  SpotifyTrackBloc spotifyTrackBloc;

  @override
  void initState() {
    spotifyTrackBloc = spotifyTrackBloc =
        SpotifyTrackBloc(spotifyPlaylist, importTargetSetList: _targetSetList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Import to ${_targetSetList.description}'),
        actions: <Widget>[
          StreamBuilder<HashMap<String, ItemSelection>>(
            builder: (BuildContext context,
                AsyncSnapshot<HashMap<String, ItemSelection>>
                    selectedItemMapSnapshot) {
              return StreamBuilder<SaveStatus>(
                  stream: spotifyTrackBloc.saveStatusStream,
                  initialData: spotifyTrackBloc.saveStatus,
                  builder: (BuildContext context,
                      AsyncSnapshot<SaveStatus> saveStatusSnapshot) {
                    return IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: saveStatusSnapshot.data.total > 0
                          ? null
                          : () async {
                              if (selectedItemMapSnapshot.hasData) {
                                await spotifyTrackBloc.importItems(
                                    _targetSetList,
                                    selectedItemMapSnapshot.data);

                                // wait a second to show the 100%
                                await Future<void>.delayed(
                                    const Duration(seconds: 1));

                                Navigator.popUntil(
                                  context,
                                  (Route<dynamic> route) {
                                    return route.settings.name ==
                                        ApplicationRouter.ROUTE_TRACK_LIST;
                                  },
                                );
                              }
                            },
                    );
                  });
            },
            stream: spotifyTrackBloc.selectedItems,
          )
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<SaveStatus>(
          stream: spotifyTrackBloc.saveStatusStream,
          initialData: spotifyTrackBloc.saveStatus,
          builder: (BuildContext context,
              AsyncSnapshot<SaveStatus> saveStatusSnapshot) {
            final bool showProgress = saveStatusSnapshot.data.total > 0;
            final double ratio = showProgress
                ? saveStatusSnapshot.data.progress /
                    saveStatusSnapshot.data.total
                : 0;
            return ModalProgressHUD(
              inAsyncCall: showProgress,
              opacity: 0.95,
              progressIndicator: CircularPercentIndicator(
                radius: 120,
                lineWidth: 13,
                animation: true,
                backgroundColor: Colors.grey,
                progressColor: Colors.blue,
                header: const Text('Building Click Tracks'),
                center: Text((ratio * 100).floor().toString() + '%'),
                percent: ratio,
              ),
              child: Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
                child: Container(
                  //This is where the magic starts
                  child: Provider<SpotifyTrackBloc>.value(
                    value: spotifyTrackBloc,
                    child: SpotifyTrackList<SpotifyTrackCardMultiSelect>(
                        (SpotifyTrack a, HashMap<String, ItemSelection> b) =>
                            SpotifyTrackCardMultiSelect(a, b)),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: CommonBottomBar(),
    );
  }

  @override
  void dispose() {
    spotifyTrackBloc.dispose();
    super.dispose();
  }
}
