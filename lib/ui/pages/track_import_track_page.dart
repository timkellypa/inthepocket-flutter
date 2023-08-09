import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/track_card_multiselect.dart';
import 'package:in_the_pocket/ui/components/common_bottom_bar.dart';
import 'package:provider/provider.dart';

import '../components/lists/track_import_list.dart';
import '../navigation/application_router.dart';

class TrackImportTrackPage extends StatefulWidget {
  const TrackImportTrackPage(this._targetSetlist, {Key? key, this.setlist})
      : super(key: key);

  final Setlist? setlist;
  final Setlist? _targetSetlist;

  @override
  State<StatefulWidget> createState() {
    return TrackImportTrackPageState(_targetSetlist, setlist);
  }
}

class TrackImportTrackPageState extends State<TrackImportTrackPage> {
  TrackImportTrackPageState(this._targetSetlist, this.setlist);

  Setlist? setlist;
  final Setlist? _targetSetlist;

  late TrackBloc trackBloc;

  @override
  void initState() {
    trackBloc = TrackBloc(setlist, importTargetSetlist: _targetSetlist);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Import to ${_targetSetlist?.description ?? ''}'),
        actions: <Widget>[
          StreamBuilder<HashMap<String, ItemSelection>>(
            builder: (BuildContext context,
                AsyncSnapshot<HashMap<String, ItemSelection>>
                    selectedItemMapSnapshot) {
              return IconButton(
                icon: const Icon(Icons.save),
                onPressed: () async {
                  if (selectedItemMapSnapshot.hasData) {
                    final List<SetlistTrack?> entries =
                        trackBloc.getMatchingSelections(SelectionType.selected);
                    entries.sort((SetlistTrack? a, SetlistTrack? b) =>
                        (a == null || b == null) ? 0 : a.sortOrder!.compareTo(b.sortOrder!));
                    for (SetlistTrack? setlistTrack in entries) {
                      if (setlistTrack == null) {
                        continue;
                      }
                      final SetlistTrack newSetlistTrack =
                          SetlistTrack();
                      newSetlistTrack.setlistId = _targetSetlist!.id;
                      newSetlistTrack.trackId = setlistTrack.trackId;
                      newSetlistTrack.notes = setlistTrack.notes;
                      await trackBloc.insert(newSetlistTrack);

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
              child: TrackImportList<TrackCardMultiSelect>(
                  (SetlistTrack a, HashMap<String, ItemSelection> b) =>
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
