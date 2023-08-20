import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/track_card_sud.dart';
import 'package:in_the_pocket/ui/navigation/application_router.dart';
import 'package:in_the_pocket/ui/navigation/edit_track_form_route_arguments.dart';
import 'package:in_the_pocket/ui/navigation/track_import_setlist_arguments.dart';
import 'package:provider/provider.dart';

import '../components/lists/track_list.dart';
import '../components/new_item_button.dart';
import '../components/track_player.dart';
import '../navigation/track_import_spotify_playlist_arguments.dart';

class TrackListPage extends StatefulWidget {
  const TrackListPage({Key? key, this.setlist}) : super(key: key);

  final Setlist? setlist;

  @override
  State<StatefulWidget> createState() {
    return TrackListPageState(setlist);
  }
}

class TrackListPageState extends State<TrackListPage> {
  TrackListPageState(this.setlist);

  Setlist? setlist;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey(debugLabel: 'scaffoldKey');

  late TrackBloc trackBloc;
  late StreamSubscription<HashMap<String, ItemSelection>>
      selectedItemSubscription;

  @override
  void initState() {
    trackBloc = TrackBloc(setlist);
    selectedItemSubscription =
        trackBloc.selectedItems.listen(itemSelectionsChanged);
    super.initState();
  }

  Future<void> itemSelectionsChanged(
      HashMap<String, ItemSelection> itemSelectionMap) async {
    final List<SetlistTrack?> selectedItems = trackBloc
        .getMatchingSelections(SelectionType.editing + SelectionType.add);

    if (selectedItems.isEmpty) {
      return;
    }

    final SetlistTrack? selectedSetlistTrack = selectedItems.first;
    final int selectionType =
        itemSelectionMap[selectedSetlistTrack?.id ?? '']?.selectionType ?? 0;
    if (selectionType & (SelectionType.editing + SelectionType.add) > 0) {
      await Navigator.pushNamed(
        context,
        ApplicationRouter.ROUTE_EDIT_TRACK_FORM,
        arguments: EditTrackFormRouteArguments(
          trackBloc,
          setlist,
          selectedSetlistTrack,
          itemSelectionMap,
        ),
      );
      await trackBloc.fetch();
    }
  }

  Future<void> importPressed(BuildContext context) async {
    await Navigator.pushNamed(
      context,
      ApplicationRouter.ROUTE_TRACK_IMPORT_SETLIST,
      arguments: TrackImportSetlistArguments(
        trackBloc,
        setlist,
      ),
    );
    await trackBloc.fetch();
  }

  Future<void> spotifyPressed(BuildContext context) async {
    await Navigator.pushNamed(
      context,
      ApplicationRouter.ROUTE_TRACK_IMPORT_SPOTIFY_PLAYLIST,
      arguments: TrackImportSpotifyPlaylistArguments(
        trackBloc,
        setlist,
      ),
    );
    await trackBloc.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Track List'),
          actions: <Widget>[
            IconButton(
                icon: const Icon(FontAwesomeIcons.spotify),
                tooltip: 'import from Spotify',
                onPressed: () {
                  spotifyPressed(context);
                }),
            IconButton(
              onPressed: () {
                importPressed(context);
              },
              icon: const Icon(FontAwesomeIcons.fileImport),
              tooltip: 'import',
            )
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
                child: Container(
                  //This is where the magic starts
                  child: Provider<TrackBloc>.value(
                    value: trackBloc,
                    child: TrackList<TrackCardSUD>(
                        (SetlistTrack a, HashMap<String, ItemSelection> b) =>
                            TrackCardSUD(a, b)),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Provider<TrackBloc>.value(
          value: trackBloc,
          child: TrackPlayer(),
        ),
        floatingActionButton:
            NewItemButton<SetlistTrack>(modelBloc: trackBloc));
  }

  @override
  void dispose() {
    trackBloc.dispose();
    selectedItemSubscription.cancel();
    super.dispose();
  }
}
