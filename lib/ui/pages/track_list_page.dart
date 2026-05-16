import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/classes/setlist_progress.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/track_card_sud.dart';
import 'package:in_the_pocket/ui/components/setlist_progress_card.dart';
import 'package:in_the_pocket/ui/navigation/application_router.dart';
import 'package:in_the_pocket/ui/navigation/edit_track_form_route_arguments.dart';
import 'package:in_the_pocket/ui/navigation/track_import_setlist_arguments.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../components/lists/track_list.dart';
import '../components/track_player.dart';
import '../navigation/track_import_spotify_playlist_arguments.dart';

const double panelExpandedHeight = 525;
const double panelCollapsedHeight = 250;
const double toolbarHeight = 56;
const double toolbarMargin = 20;
const double approximateCardHeight = 64;

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

  bool _panelExpanded = false;
  double _bottomMargin = panelCollapsedHeight + toolbarHeight + toolbarMargin;

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

  Future<void> ensureSelectedIsVisible() async {
    final List<SetlistTrack?> selectedItems =
        trackBloc.getMatchingSelections(SelectionType.selected);

    if (selectedItems.length == 1) {
      final SetlistTrack track = selectedItems.first!;
      BuildContext? context = track.cardKey.currentContext;
      if (context == null) {
        final int itemIndex = trackBloc.itemList.indexOf(track);
        double itemScrollPosition = approximateCardHeight * itemIndex;
        itemScrollPosition = min(itemScrollPosition,
            trackBloc.scrollController.position.maxScrollExtent);
        await trackBloc.scrollController.animateTo(itemScrollPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }

      void finishScroll(BuildContext itemContext) {
        Scrollable.ensureVisible(itemContext,
            duration: const Duration(milliseconds: 300), // Time for animation
            curve: Curves.easeInOut,
            alignmentPolicy: ScrollPositionAlignmentPolicy.explicit);
      }

      if (context != null) {
        finishScroll(context);
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context = track.cardKey.currentContext;
          if (context != null) {
            finishScroll(context!);
          }
        });
      }
    }
  }

  Future<void> itemSelectionsChanged(
      HashMap<String, ItemSelection> itemSelectionMap) async {
    final List<SetlistTrack?> selectedItemsForAddOrEdit = trackBloc
        .getMatchingSelections(SelectionType.editing + SelectionType.add);

    ensureSelectedIsVisible();

    if (selectedItemsForAddOrEdit.isEmpty) {
      return;
    }

    final SetlistTrack? selectedSetlistTrack = selectedItemsForAddOrEdit.first;
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

  void addNewTrack() {
    setState(() => trackBloc.selectItem(null, SelectionType.add));
  }

  void startSetlist() {
    setState(() => trackBloc.startSetList());
  }

  void pauseSetlist() {
    setState(() => trackBloc.pauseSetList());
  }

  void stopSetlist() {
    setState(() => trackBloc.stopSetList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Track List'),
        actions: <Widget>[
          IconButton(
              icon: Icon(FontAwesomeIcons.plus.data),
              tooltip: 'add track',
              onPressed: () {
                addNewTrack();
              }),
          if (trackBloc.setlistProgress.startTime == null ||
              trackBloc.setlistProgress.isPaused)
            IconButton(
              icon: Icon(FontAwesomeIcons.play.data),
              tooltip: 'start setlist',
              onPressed: () {
                startSetlist();
              },
            ),
          if (trackBloc.setlistProgress.startTime != null &&
              !trackBloc.setlistProgress.isPaused)
            IconButton(
              icon: Icon(FontAwesomeIcons.pause.data),
              tooltip: 'pause setlist',
              onPressed: () {
                pauseSetlist();
              },
            ),
          if (trackBloc.setlistProgress.startTime != null)
            IconButton(
              icon: Icon(FontAwesomeIcons.stop.data),
              tooltip: 'stop setlist',
              onPressed: () {
                stopSetlist();
              },
            ),
          IconButton(
              icon: Icon(FontAwesomeIcons.spotify.data),
              tooltip: 'import from Spotify',
              onPressed: () {
                spotifyPressed(context);
              }),
          IconButton(
            onPressed: () {
              importPressed(context);
            },
            icon: Icon(FontAwesomeIcons.fileImport.data),
            tooltip: 'import',
          ),
        ],
      ),
      body: SlidingUpPanel(
        color: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            margin: EdgeInsets.only(bottom: _bottomMargin),
            padding: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
            child: Container(
              //This is where the magic starts
              child: Provider<TrackBloc>.value(
                value: trackBloc,
                child: Column(
                  children: <Widget>[
                    StreamBuilder<SetlistProgress>(
                        stream: trackBloc.setlistProgressStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<SetlistProgress> snapshot) {
                          final SetlistProgress? setlistProgress =
                              snapshot.data;
                          if (setlistProgress == null) {
                            return Container();
                          }

                          return SetlistProgressCard(
                              setlistProgress: setlistProgress);
                        }),
                    Expanded(
                        child: Container(
                      child: TrackList<TrackCardSUD>(
                          (SetlistTrack a, HashMap<String, ItemSelection> b) =>
                              TrackCardSUD(a, b)),
                    ))
                  ],
                ),
              ),
            ),
          ),
        ),
        minHeight: panelCollapsedHeight,
        maxHeight: panelExpandedHeight,
        panel: Provider<TrackBloc>.value(
          value: trackBloc,
          child: TrackPlayer(
              panelExpanded: _panelExpanded,
              minHeight: panelCollapsedHeight,
              maxHeight: panelExpandedHeight),
        ),
        onPanelClosed: () => <void>{
          setState(() {
            _panelExpanded = false;
            ensureSelectedIsVisible();
          })
        },
        onPanelOpened: () => <void>{
          setState(() {
            _panelExpanded = true;
            ensureSelectedIsVisible();
          })
        },
        onPanelSlide: (double position) {
          setState(() {
            // Linearly interpolates the margin between min and max heights
            _bottomMargin = panelCollapsedHeight +
                (panelExpandedHeight - panelCollapsedHeight) * position +
                toolbarHeight +
                toolbarMargin;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    trackBloc.dispose();
    selectedItemSubscription.cancel();
    super.dispose();
  }
}
