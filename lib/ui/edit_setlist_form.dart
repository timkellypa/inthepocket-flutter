import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/setlist_bloc.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/ui/controls/date_time.dart';
import 'package:provider/provider.dart';

class EditSetListForm extends StatefulWidget {
  const EditSetListForm({this.setList});
  final SetListProxy setList;

  @override
  State<StatefulWidget> createState() {
    return EditSetListFormState(setList);
  }
}

class EditSetListFormState extends State<EditSetListForm> {
  EditSetListFormState(this.setList);

  SetListProxy setList;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isMasterList = false;

  @override
  void initState() {
    if (setList != null) {
      _descriptionController.text = setList.description;
      _dateTimeController.text = setList.date.toString();
      _locationController.text = setList.location;
      _isMasterList = setList.isMaster;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final SetListBloc setListBloc = Provider.of<SetListBloc>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Set List Info'), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () {
            final SetListProxy setListToSave = setList ?? SetListProxy();

            setListToSave.description = _descriptionController.value.text;

            setListToSave.date = DateTime.now();
            setListToSave.isMaster = _isMasterList;
            setListToSave.location = _locationController.value.text;
            setListToSave.date =
                DateTime.tryParse(_dateTimeController.value.text) ??
                    DateTime.now();

            if (setListToSave.description.isNotEmpty) {
              if (setList != null) {
                setListBloc.update(setListToSave);
              } else {
                setListBloc.insert(setListToSave);
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
                  value: _isMasterList,
                  onChanged: (bool check) {
                    setState(() => _isMasterList = check);
                  }),
              Visibility(
                  visible: !_isMasterList,
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: DateTimeControl(_dateTimeController),
                    subtitle: const Text('Date/Time'),
                  )),
              Visibility(
                  visible: !_isMasterList,
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
