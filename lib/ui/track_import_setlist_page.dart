import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/setlist_bloc.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/ui/components/cards/setlist_card_select.dart';
import 'package:in_the_pocket/ui/navigation/application_router.dart';
import 'package:in_the_pocket/ui/navigation/track_import_track_arguments.dart';
import 'package:provider/provider.dart';

import 'components/common_bottom_bar.dart';
import 'components/lists/setlist_list.dart';

class TrackImportSetlistPage extends StatefulWidget {
  const TrackImportSetlistPage(this._targetSetList, {Key key})
      : super(key: key);

  final SetListProxy _targetSetList;

  @override
  State<StatefulWidget> createState() {
    return TrackImportSetlistPageState(_targetSetList);
  }
}

class TrackImportSetlistPageState extends State<TrackImportSetlistPage> {
  TrackImportSetlistPageState(this._targetSetList);

  final SetListProxy _targetSetList;

  TrackBloc trackBloc;
  SetListBloc setListBloc;
  StreamSubscription<HashMap<String, ItemSelection>> selectedItemSubscription;

  @override
  void initState() {
    setListBloc =
        setListBloc = SetListBloc(importTargetSetList: _targetSetList);
    selectedItemSubscription =
        setListBloc.selectedItems.listen(itemSelectionsChanged);
    super.initState();
  }

  void itemSelectionsChanged(HashMap<String, ItemSelection> itemSelectionMap) {
    final List<SetListProxy> selectedItems =
        setListBloc.getMatchingSelections(SelectionType.selected);

    if (selectedItems.isEmpty) {
      return;
    }

    final SetListProxy selectedSetList = selectedItems.first;

    Navigator.pushNamed(
      context,
      ApplicationRouter.ROUTE_TRACK_IMPORT_TRACK,
      arguments: TrackImportTrackArguments(
        setListBloc,
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
            child: Provider<SetListBloc>.value(
              value: setListBloc,
              child: SetListList<SetListCardSelect>(
                  (SetListProxy a, HashMap<String, ItemSelection> b) =>
                      SetListCardSelect(a, b)),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CommonBottomBar(),
    );
  }

  @override
  void dispose() {
    setListBloc.dispose();
    selectedItemSubscription.cancel();
    super.dispose();
  }
}
