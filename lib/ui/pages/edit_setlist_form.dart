import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/setlist_bloc.dart';
import 'package:in_the_pocket/classes/setlist_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/controls/date_time.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditSetlistForm extends StatefulWidget {
  const EditSetlistForm({this.setlist});
  final Setlist? setlist;

  @override
  State<StatefulWidget> createState() {
    return EditSetlistFormState(setlist);
  }
}

class EditSetlistFormState extends State<EditSetlistForm> {
  EditSetlistFormState(this.setlist);

  Setlist? setlist;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  SetlistType _setlistType = SetlistType.master;

  @override
  void initState() {
    final DateFormat dateFormat = DateTimeControlState.dateFormat;

    _descriptionController.text = setlist?.description ?? '';

    try {
      _dateTimeController.text =
          dateFormat.format(setlist?.date ?? DateTime.now());
    } on FormatException {
      _dateTimeController.text = dateFormat.format(DateTime.now());
    }

    _locationController.text = setlist?.location ?? '';
    _setlistType = SetlistType.values[setlist?.setlistType ?? 0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SetlistBloc setlistBloc = Provider.of<SetlistBloc>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Set List Info'), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () async {
            final Setlist setlistToSave = setlist ?? Setlist();

            setlistToSave.description = _descriptionController.value.text;

            final DateFormat dateFormat = DateTimeControlState.dateFormat;

            try {
              setlistToSave.date = dateFormat.parse(_dateTimeController.text);
            } on FormatException {
              setlistToSave.date = DateTime.now();
            }
            setlistToSave.setlistType = _setlistType.index;
            setlistToSave.location = _locationController.value.text;

            if (setlistToSave.description!.isNotEmpty) {
              if (setlist != null) {
                await setlistBloc.update(setlistToSave);
              } else {
                await setlistBloc.insert(setlistToSave);
              }

              Navigator.pop(context);
            }
          },
        )
      ]),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: ListView(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.description),
                title: TextField(controller: _descriptionController),
                subtitle: const Text('Description'),
              ),
              CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Is Master List'),
                  value: _setlistType == SetlistType.master,
                  onChanged: (bool? check) {
                    setState(() => _setlistType = (check ?? false)
                        ? SetlistType.master
                        : SetlistType.event);
                  }),
              Visibility(
                  visible: _setlistType == SetlistType.event,
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: DateTimeControl(_dateTimeController),
                    subtitle: const Text('Date'),
                  )),
              Visibility(
                  visible: _setlistType == SetlistType.event,
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: TextField(controller: _locationController),
                    subtitle: const Text('Location'),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
