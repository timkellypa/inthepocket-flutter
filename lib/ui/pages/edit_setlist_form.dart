import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/setlist_bloc.dart';
import 'package:in_the_pocket/classes/setlist_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/controls/date_time.dart';
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
    _descriptionController.text = setlist?.description ?? '';
    _dateTimeController.text = setlist?.date?.toString() ?? '';
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

            setlistToSave.date = DateTime.now();
            setlistToSave.setlistType = _setlistType.index;
            setlistToSave.location = _locationController.value.text;
            setlistToSave.date =
                DateTime.tryParse(_dateTimeController.value.text) ??
                    DateTime.now();

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
          child: Column(
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
                    setState(() => _setlistType =
                        (check ?? false) ? SetlistType.master : SetlistType.event);
                  }),
              Visibility(
                  visible: _setlistType == SetlistType.event,
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: DateTimeControl(_dateTimeController),
                    subtitle: const Text('Date/Time'),
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
