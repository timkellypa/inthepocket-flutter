import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/tempo_bloc.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/models/independent/setlist_track.g.m8.dart';
import 'package:in_the_pocket/models/independent/tempo.g.m8.dart';
import 'package:in_the_pocket/models/independent/track.g.m8.dart';
import 'package:in_the_pocket/ui/components/cards/tempo_card_sud.dart';
import 'package:in_the_pocket/ui/components/lists/tempo_list.dart';
import 'package:provider/provider.dart';

import 'components/cards/tempo_card.dart';

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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    if (setListTrack != null) {
      _titleController.text = setListTrack.track.title;
      _notesController.text = setListTrack.notes;
    }
    super.initState();
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
    );
  }

  Widget buildTempoList() {
    if (setListTrack == null) {
      return null;
    }

    return Expanded(
      child: Provider<TempoBloc>(
        builder: (BuildContext context) => TempoBloc(setListTrack.track),
        child: TempoList<TempoCardSUD>(
            (TempoProxy a, HashMap<TempoProxy, ItemSelection> b) =>
                TempoCardSUD(a, b)),
      ),
    );
  }
}
