import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/setlist_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/setlist_card_select.dart';
import 'package:in_the_pocket/ui/navigation/application_router.dart';
import 'package:in_the_pocket/ui/navigation/track_import_track_arguments.dart';
import 'package:provider/provider.dart';

import '../components/common_bottom_bar.dart';
import '../components/lists/setlist_list.dart';

class TrackImportSetlistPage extends StatefulWidget {
  const TrackImportSetlistPage(this._targetSetlist, {Key? key})
      : super(key: key);

  final Setlist _targetSetlist;

  @override
  State<StatefulWidget> createState() {
    return TrackImportSetlistPageState(_targetSetlist);
  }
}

class TrackImportSetlistPageState extends State<TrackImportSetlistPage> {
  TrackImportSetlistPageState(this._targetSetlist);

  final Setlist _targetSetlist;

  late SetlistBloc setlistBloc;
  late StreamSubscription<HashMap<String, ItemSelection>> selectedItemSubscription;

  @override
  void initState() {
    setlistBloc =
        setlistBloc = SetlistBloc(importTargetSetlist: _targetSetlist);
    selectedItemSubscription =
        setlistBloc.selectedItems.listen(itemSelectionsChanged);
    super.initState();
  }

  void itemSelectionsChanged(HashMap<String, ItemSelection> itemSelectionMap) {
    final List<Setlist?> selectedItems =
        setlistBloc.getMatchingSelections(SelectionType.selected);

    if (selectedItems.isEmpty) {
      return;
    }

    final Setlist? selectedSetlist = selectedItems.first;

    Navigator.pushNamed(
      context,
      ApplicationRouter.ROUTE_TRACK_IMPORT_TRACK,
      arguments: TrackImportTrackArguments(
        setlistBloc,
        _targetSetlist,
        selectedSetlist,
        itemSelectionMap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Import to ${_targetSetlist.description}')),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
          child: Container(
            //This is where the magic starts
            child: Provider<SetlistBloc>.value(
              value: setlistBloc,
              child: SetlistList<SetlistCardSelect>(
                  (Setlist a, HashMap<String, ItemSelection> b) =>
                      SetlistCardSelect(a, b)),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CommonBottomBar(),
    );
  }

  @override
  void dispose() {
    setlistBloc.dispose();
    selectedItemSubscription.cancel();
    super.dispose();
  }
}
