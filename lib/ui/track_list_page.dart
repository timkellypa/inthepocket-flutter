import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/helpers/item_selection_helpers.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';
import 'package:in_the_pocket/ui/components/cards/track_card_sud.dart';
import 'package:in_the_pocket/ui/components/common_bottom_bar.dart';
import 'package:in_the_pocket/ui/navigation/application_router.dart';
import 'package:in_the_pocket/ui/navigation/edit_track_form_route_arguments.dart';
import 'package:in_the_pocket/ui/navigation/track_import_setlist_arguments.dart';
import 'package:provider/provider.dart';

import 'components/lists/track_list.dart';
import 'components/new_item_button.dart';
import 'navigation/track_import_spotify_playlist_arguments.dart';

class TrackListPage extends StatefulWidget {
  const TrackListPage({Key key, this.setList}) : super(key: key);

  final SetListProxy setList;

  @override
  State<StatefulWidget> createState() {
    return TrackListPageState(setList);
  }
}

class TrackListPageState extends State<TrackListPage> {
  TrackListPageState(this.setList);

  SetListProxy setList;

  TrackBloc trackBloc;
  StreamSubscription<HashMap<SetListTrackProxy, ItemSelection>>
      selectedItemSubscription;

  @override
  void initState() {
    trackBloc = TrackBloc(setList);
    selectedItemSubscription =
        trackBloc.selectedItems.listen(itemSelectionsChanged);
    super.initState();
  }

  void itemSelectionsChanged(
      HashMap<SetListTrackProxy, ItemSelection> itemSelectionMap) {
    final List<SetListTrackProxy> selectedItems =
        ItemSelectionHelpers.getItemSelectionMatches<SetListTrackProxy>(
            itemSelectionMap,
            SelectionType.editing + SelectionType.add + SelectionType.selected);

    if (selectedItems.isEmpty) {
      return;
    }

    final SetListTrackProxy selectedSetListTrack = selectedItems.first;
    final int selectionType =
        itemSelectionMap[selectedSetListTrack].selectionType;
    if (selectionType & (SelectionType.editing + SelectionType.add) > 0) {
      Navigator.pushNamed(
        context,
        ApplicationRouter.ROUTE_EDIT_TRACK_FORM,
        arguments: EditTrackFormRouteArguments(
          trackBloc,
          setList,
          selectedSetListTrack,
          itemSelectionMap,
        ),
      );
    }
  }

  void importPressed(BuildContext context) {
    Navigator.pushNamed(
      context,
      ApplicationRouter.ROUTE_TRACK_IMPORT_SETLIST,
      arguments: TrackImportSetListArguments(
        trackBloc,
        setList,
      ),
    );
  }

  void spotifyPressed(BuildContext context) {
    Navigator.pushNamed(
      context,
      ApplicationRouter.ROUTE_TRACK_IMPORT_SPOTIFY_PLAYLIST,
      arguments: TrackImportSpotifyPlaylistArguments(
        trackBloc,
        setList,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: const Text('Track List'),
        actions: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.spotify),
              tooltip: 'import from Spotify',
              onPressed: () {
                spotifyPressed(context);
              }),
          IconButton(
            onPressed: () {
              importPressed(context);
            },
            icon: Icon(FontAwesomeIcons.fileImport),
            tooltip: 'import',
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
          child: Container(
            //This is where the magic starts
            child: Provider<TrackBloc>.value(
              value: trackBloc,
              child: TrackList<TrackCardSUD>((SetListTrackProxy a,
                      HashMap<SetListTrackProxy, ItemSelection> b) =>
                  TrackCardSUD(a, b)),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CommonBottomBar(),
      floatingActionButton:
          NewItemButton<SetListTrackProxy>(modelBloc: trackBloc),
    );
  }

  @override
  void dispose() {
    trackBloc.dispose();
    selectedItemSubscription.cancel();
    super.dispose();
  }
}
