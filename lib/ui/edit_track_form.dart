import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/tempo_bloc.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/helpers/item_selection_helpers.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';
import 'package:in_the_pocket/models/independent/tempo.g.m8.dart';
import 'package:in_the_pocket/models/independent/track.g.m8.dart';
import 'package:in_the_pocket/ui/components/cards/tempo_card_sud.dart';
import 'package:in_the_pocket/ui/components/lists/tempo_list.dart';
import 'package:in_the_pocket/ui/navigation/edit_tempo_form_route_arguments.dart';
import 'package:provider/provider.dart';

import 'components/new_item_button.dart';
import 'navigation/application_router.dart';

class EditTrackForm extends StatefulWidget {
  const EditTrackForm(this.setList, {this.setListTrack});
  final SetListTrackProxy setListTrack;
  final SetListProxy setList;

  @override
  State<StatefulWidget> createState() {
    return EditSetListFormState(setList, setListTrack);
  }
}

class EditSetListFormState extends State<EditTrackForm> {
  EditSetListFormState(this.setList, this.setListTrack);

  SetListProxy setList;
  SetListTrackProxy setListTrack;
  TempoBloc tempoBloc;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    if (setListTrack != null) {
      _titleController.text = setListTrack.track.title;
      _notesController.text = setListTrack.notes;
      tempoBloc = TempoBloc(setListTrack.track);
    } else {
      // Use a placeholder track with -1 ID if track is not saved yet.
      tempoBloc = TempoBloc(TrackProxy()..id = -1);
    }

    tempoBloc.selectedItems.listen(itemSelectionsChanged);

    super.initState();
  }

  void itemSelectionsChanged(
      HashMap<TempoProxy, ItemSelection> itemSelectionMap) {
    final List<TempoProxy> selectedItems =
        ItemSelectionHelpers.getItemSelectionMatches<TempoProxy>(
            itemSelectionMap, SelectionType.editing + SelectionType.add);

    if (selectedItems.isEmpty) {
      return;
    }

    final TempoProxy selectedTempo = selectedItems.first;
    final int selectionType = itemSelectionMap[selectedTempo].selectionType;
    if (selectionType & (SelectionType.editing + SelectionType.add) > 0) {
      Navigator.pushNamed(
        context,
        ApplicationRouter.ROUTE_EDIT_TEMPO_FORM,
        arguments: EditTempoFormRouteArguments(
          tempoBloc,
          selectedTempo,
          itemSelectionMap,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TrackBloc trackBloc = Provider.of<TrackBloc>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Track Info'), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () {
            final SetListTrackProxy setListTrackToSave =
                setListTrack ?? SetListTrackProxy();

            setListTrackToSave.setListId = setList.id;

            setListTrackToSave.track ??= TrackProxy();

            setListTrackToSave.track.title = _titleController.value.text;

            setListTrackToSave.notes = _notesController.value.text;

            if (setListTrackToSave.track.title.isNotEmpty) {
              if (setListTrack != null) {
                trackBloc.update(setListTrackToSave);
              } else {
                trackBloc.insert(setListTrackToSave);
              }

              Navigator.pop(context);
            }
          },
        )
      ]),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.title),
                title: TextField(controller: _titleController),
                subtitle: const Text('Title'),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: TextField(controller: _notesController),
                subtitle: const Text('Notes'),
              ),
              buildTempoList()
            ],
          ),
        ),
      ),
      floatingActionButton: NewItemButton<TempoProxy>(modelBloc: tempoBloc),
    );
  }

  Widget buildTempoList() {
    return Expanded(
      child: Provider<TempoBloc>(
        builder: (BuildContext context) => tempoBloc,
        child: TempoList<TempoCardSUD>(
            (TempoProxy a, HashMap<TempoProxy, ItemSelection> b) =>
                TempoCardSUD(a, b)),
      ),
    );
  }

  @override
  Future<void> dispose() async {
    tempoBloc.clearPlaceholderTempos();
    super.dispose();
  }
}
