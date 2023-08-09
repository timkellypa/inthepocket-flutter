import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/tempo_bloc.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/tempo_card_sud.dart';
import 'package:in_the_pocket/ui/components/lists/tempo_list.dart';
import 'package:in_the_pocket/ui/navigation/edit_tempo_form_route_arguments.dart';
import 'package:provider/provider.dart';

import '../components/new_item_button.dart';
import '../navigation/application_router.dart';

class EditTrackForm extends StatefulWidget {
  const EditTrackForm(this.setlist, {this.setlistTrack});
  final SetlistTrack? setlistTrack;
  final Setlist setlist;

  @override
  State<StatefulWidget> createState() {
    return EditSetlistFormState(setlist, setlistTrack);
  }
}

class EditSetlistFormState extends State<EditTrackForm> {
  EditSetlistFormState(this.setlist, this.setlistTrack);

  Setlist setlist;
  SetlistTrack? setlistTrack;
  late TempoBloc tempoBloc;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    setlistTrack ??= SetlistTrack();
    setlistTrack!.plTrack ??= Track();
    _titleController.text = setlistTrack!.plTrack!.title ?? '';
    _notesController.text = setlistTrack!.plTrack!.notes ?? '';
    tempoBloc = TempoBloc(setlistTrack!.plTrack!);

    tempoBloc.selectedItems.listen(itemSelectionsChanged);

    super.initState();
  }

  void itemSelectionsChanged(HashMap<String, ItemSelection> itemSelectionMap) {
    final List<Tempo?> selectedItems = tempoBloc
        .getMatchingSelections(SelectionType.editing + SelectionType.add);

    if (selectedItems.isEmpty) {
      return;
    }

    final Tempo? selectedTempo = selectedItems.first;
    final int selectionType =
        itemSelectionMap[selectedTempo?.id ?? '']?.selectionType ?? SelectionType.add;
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
            final SetlistTrack setlistTrackToSave =
                setlistTrack ?? SetlistTrack();

            setlistTrackToSave.setlistId = setlist.id;

            setlistTrackToSave.plTrack ??= Track();

            setlistTrackToSave.plTrack!.title = _titleController.value.text;

            setlistTrackToSave.notes = _notesController.value.text;

            if (setlistTrackToSave.plTrack!.title!.isNotEmpty) {
              if (setlistTrack?.id != null) {
                trackBloc.update(setlistTrackToSave);
              } else {
                trackBloc.insert(setlistTrackToSave);
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
      floatingActionButton: NewItemButton<Tempo>(modelBloc: tempoBloc),
    );
  }

  Widget buildTempoList() {
    return Expanded(
      child: Provider<TempoBloc>(
        create: (BuildContext context) => tempoBloc,
        child: TempoList<TempoCardSUD>(
            (Tempo a, HashMap<String, ItemSelection> b) =>
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
