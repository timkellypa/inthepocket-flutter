import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';
import 'package:in_the_pocket/ui/components/cards/track_card_multiselect.dart';
import 'package:in_the_pocket/ui/components/common_bottom_bar.dart';
import 'package:provider/provider.dart';

import 'components/lists/track_import_list.dart';
import 'navigation/application_router.dart';

class TrackImportTrackPage extends StatefulWidget {
  const TrackImportTrackPage(this._targetSetList, {Key key, this.setList})
      : super(key: key);

  final SetListProxy setList;
  final SetListProxy _targetSetList;

  @override
  State<StatefulWidget> createState() {
    return TrackImportTrackPageState(_targetSetList, setList);
  }
}

class TrackImportTrackPageState extends State<TrackImportTrackPage> {
  TrackImportTrackPageState(this._targetSetList, this.setList);

  SetListProxy setList;
  final SetListProxy _targetSetList;

  TrackBloc trackBloc;

  @override
  void initState() {
    trackBloc = TrackBloc(setList, importTargetSetList: _targetSetList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Import to ${_targetSetList.description}'),
        actions: <Widget>[
          StreamBuilder<HashMap<SetListTrackProxy, ItemSelection>>(
            builder: (BuildContext context,
                AsyncSnapshot<HashMap<SetListTrackProxy, ItemSelection>>
                    selectedItemMapSnapshot) {
              return IconButton(
                icon: Icon(Icons.save),
                onPressed: () async {
                  if (selectedItemMapSnapshot.hasData) {
                    final HashMap<SetListTrackProxy, ItemSelection>
                        selectedItemMap = selectedItemMapSnapshot.data;
                    final List<MapEntry<SetListTrackProxy, ItemSelection>>
                        entries = selectedItemMap.entries.toList();
                    entries.sort((MapEntry<SetListTrackProxy, ItemSelection> a,
                            MapEntry<SetListTrackProxy, ItemSelection> b) =>
                        a.key.sortOrder.compareTo(b.key.sortOrder));
                    for (MapEntry<SetListTrackProxy, ItemSelection> entry
                        in entries) {
                      if (entry.value.selectionType & SelectionType.selected >
                          0) {
                        final SetListTrackProxy newSetListTrackProxy =
                            SetListTrackProxy();
                        newSetListTrackProxy.setListId = _targetSetList.id;
                        newSetListTrackProxy.trackId = entry.key.trackId;
                        newSetListTrackProxy.notes = entry.key.notes;
                        await trackBloc.insert(newSetListTrackProxy);
                      }

                      Navigator.popUntil(context, (Route<dynamic> route) {
                        return route.settings.name ==
                            ApplicationRouter.ROUTE_TRACK_LIST;
                      });
                    }
                  }
                },
              );
            },
            stream: trackBloc.selectedItems,
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
              child: TrackImportList<TrackCardMultiSelect>((SetListTrackProxy a,
                      HashMap<SetListTrackProxy, ItemSelection> b) =>
                  TrackCardMultiSelect(a, b)),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CommonBottomBar(),
    );
  }

  @override
  void dispose() {
    trackBloc.dispose();
    super.dispose();
  }
}
