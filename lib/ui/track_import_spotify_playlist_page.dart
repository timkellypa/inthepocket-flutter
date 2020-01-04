import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/spotify_playlist_bloc.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/helpers/item_selection_helpers.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/models/independent/spotify_playlist.dart';
import 'package:in_the_pocket/ui/components/cards/spotify_playlist_card_select.dart';
import 'package:in_the_pocket/ui/components/lists/spotify_playlist_list.dart';
import 'package:provider/provider.dart';

import 'components/common_bottom_bar.dart';
import 'navigation/application_router.dart';
import 'navigation/track_import_spotify_track_arguments.dart';

class TrackImportSpotifyPlaylistPage extends StatefulWidget {
  const TrackImportSpotifyPlaylistPage(this._targetSetList, {Key key})
      : super(key: key);

  final SetListProxy _targetSetList;

  @override
  State<StatefulWidget> createState() {
    return TrackImportSpotifyPlaylistPageState(_targetSetList);
  }
}

class TrackImportSpotifyPlaylistPageState
    extends State<TrackImportSpotifyPlaylistPage> {
  TrackImportSpotifyPlaylistPageState(this._targetSetList);

  final SetListProxy _targetSetList;

  TrackBloc trackBloc;
  SpotifyPlaylistBloc spotifyPlaylistBloc;
  StreamSubscription<HashMap<SpotifyPlaylist, ItemSelection>>
      selectedItemSubscription;

  @override
  void initState() {
    spotifyPlaylistBloc = spotifyPlaylistBloc =
        SpotifyPlaylistBloc(importTargetSetList: _targetSetList);
    selectedItemSubscription =
        spotifyPlaylistBloc.selectedItems.listen(itemSelectionsChanged);
    super.initState();
  }

  void itemSelectionsChanged(
      HashMap<SpotifyPlaylist, ItemSelection> itemSelectionMap) {
    final List<SpotifyPlaylist> selectedItems =
        ItemSelectionHelpers.getItemSelectionMatches<SpotifyPlaylist>(
            itemSelectionMap, SelectionType.selected);

    if (selectedItems.isEmpty) {
      return;
    }

    final SpotifyPlaylist selectedSetList = selectedItems.first;

    Navigator.pushNamed(
      context,
      ApplicationRouter.ROUTE_TRACK_IMPORT_SPOTIFY_TRACK,
      arguments: TrackImportSpotifyTrackArguments(
        spotifyPlaylistBloc,
        _targetSetList,
        selectedSetList,
        itemSelectionMap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(title: Text('Import to ${_targetSetList.description}')),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
          child: Container(
            //This is where the magic starts
            child: Provider<SpotifyPlaylistBloc>.value(
              value: spotifyPlaylistBloc,
              child: SpotifyPlaylistList<SpotifyPlaylistCardSelect>(
                  (SpotifyPlaylist a,
                          HashMap<SpotifyPlaylist, ItemSelection> b) =>
                      SpotifyPlaylistCardSelect(a, b)),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CommonBottomBar(),
    );
  }

  @override
  void dispose() {
    spotifyPlaylistBloc.dispose();
    selectedItemSubscription.cancel();
    super.dispose();
  }
}
