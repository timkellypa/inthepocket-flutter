import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/setlist_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/common_bottom_bar.dart';
import 'package:in_the_pocket/ui/components/new_item_button.dart';
import 'package:in_the_pocket/ui/navigation/application_router.dart';
import 'package:in_the_pocket/ui/navigation/edit_setlist_form_route_arguments.dart';
import 'package:in_the_pocket/ui/navigation/track_list_route_arguments.dart';
import 'package:provider/provider.dart';

import '../components/cards/setlist_card_sud.dart';
import '../components/lists/setlist_list.dart';

class SetlistListPage extends StatefulWidget {
  const SetlistListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SetlistListPageState();
  }
}

class SetlistListPageState extends State<SetlistListPage> {
  SetlistListPageState();

  final SetlistBloc setlistBloc = SetlistBloc();
  StreamSubscription<HashMap<String, ItemSelection>>? selectedItemSubscription;

  @override
  void initState() {
    selectedItemSubscription =
        setlistBloc.selectedItems.listen(itemSelectionsChanged);
    super.initState();
  }

  Future<void> itemSelectionsChanged(HashMap<String, ItemSelection> itemSelectionMap) async {
    final List<Setlist?> selectedItems = setlistBloc.getMatchingSelections(
        SelectionType.add + SelectionType.editing + SelectionType.selected);

    if (selectedItems.isEmpty) {
      return;
    }

    final Setlist? selectedSetlist = selectedItems.first;
    final int selectionType =
        itemSelectionMap[selectedSetlist?.id ?? '']?.selectionType ?? 0;

    if (selectionType & (SelectionType.add + SelectionType.editing) > 0) {
      await Navigator.pushNamed(
        context,
        ApplicationRouter.ROUTE_EDIT_SETLIST_FORM,
        arguments: EditSetlistFormRouteArguments(
          setlistBloc,
          selectedSetlist,
          itemSelectionMap,
        ),
      );
      await setlistBloc.fetch();
    } else {
      Navigator.pushNamed(
        context,
        ApplicationRouter.ROUTE_TRACK_LIST,
        arguments: TrackListRouteArguments(
          setlistBloc,
          selectedSetlist,
          itemSelectionMap,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('In the Pocket')),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
          child: Container(
            //This is where the magic starts
            child: Provider<SetlistBloc>(
              create: (BuildContext context) => setlistBloc,
              child: SetlistList<SetlistCardSUD>(
                  (Setlist a, HashMap<String, ItemSelection> b) =>
                      SetlistCardSUD(a, b)),
              dispose: (BuildContext context, SetlistBloc value) {
                  value.unSelectAll(
                    SelectionType.selected,
                  );
              },

            ),
          ),
        ),
      ),
      bottomNavigationBar: CommonBottomBar(),
      floatingActionButton: NewItemButton<Setlist>(modelBloc: setlistBloc),
    );
  }

  @override
  void dispose() {
    setlistBloc.dispose();
    selectedItemSubscription?.cancel();
    super.dispose();
  }
}
