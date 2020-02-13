import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/setlist_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/ui/components/common_bottom_bar.dart';
import 'package:in_the_pocket/ui/components/new_item_button.dart';
import 'package:in_the_pocket/ui/navigation/application_router.dart';
import 'package:in_the_pocket/ui/navigation/edit_setlist_form_route_arguments.dart';
import 'package:in_the_pocket/ui/navigation/track_list_route_arguments.dart';
import 'package:provider/provider.dart';

import '../components/cards/setlist_card_sud.dart';
import '../components/lists/setlist_list.dart';

class SetListListPage extends StatefulWidget {
  const SetListListPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SetListListPageState();
  }
}

class SetListListPageState extends State<SetListListPage> {
  SetListListPageState();

  final SetListBloc setListBloc = SetListBloc();
  StreamSubscription<HashMap<String, ItemSelection>> selectedItemSubscription;

  @override
  void initState() {
    selectedItemSubscription =
        setListBloc.selectedItems.listen(itemSelectionsChanged);
    super.initState();
  }

  void itemSelectionsChanged(HashMap<String, ItemSelection> itemSelectionMap) {
    final List<SetListProxy> selectedItems = setListBloc.getMatchingSelections(
        SelectionType.add + SelectionType.editing + SelectionType.selected);

    if (selectedItems.isEmpty) {
      return;
    }

    final SetListProxy selectedSetList = selectedItems.first;
    final int selectionType =
        itemSelectionMap[selectedSetList?.guid ?? ''].selectionType;

    if (selectionType & (SelectionType.add + SelectionType.editing) > 0) {
      Navigator.pushNamed(
        context,
        ApplicationRouter.ROUTE_EDIT_SETLIST_FORM,
        arguments: EditSetListFormRouteArguments(
          setListBloc,
          selectedSetList,
          itemSelectionMap,
        ),
      );
    } else {
      Navigator.pushNamed(
        context,
        ApplicationRouter.ROUTE_TRACK_LIST,
        arguments: TrackListRouteArguments(
          setListBloc,
          selectedSetList,
          itemSelectionMap,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(title: const Text('In the Pocket')),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
          child: Container(
            //This is where the magic starts
            child: Provider<SetListBloc>.value(
              value: setListBloc,
              child: SetListList<SetListCardSUD>(
                  (SetListProxy a, HashMap<String, ItemSelection> b) =>
                      SetListCardSUD(a, b)),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CommonBottomBar(),
      floatingActionButton: NewItemButton<SetListProxy>(modelBloc: setListBloc),
    );
  }

  @override
  void dispose() {
    setListBloc.dispose();
    selectedItemSubscription.cancel();
    super.dispose();
  }
}
