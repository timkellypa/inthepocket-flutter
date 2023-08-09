import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/tempo_bloc.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:provider/provider.dart';

class EditTempoForm extends StatefulWidget {
  const EditTempoForm({this.tempo});
  final Tempo? tempo;

  @override
  State<StatefulWidget> createState() {
    return EditTempoFormState(tempo);
  }
}

class EditTempoFormState extends State<EditTempoForm> {
  EditTempoFormState(this.tempo);

  Tempo? tempo;
  final TextEditingController _accentBeatsPerBarController =
      TextEditingController();
  final TextEditingController _beatsPerBarController = TextEditingController();
  final TextEditingController _beatUnitController = TextEditingController();
  final TextEditingController _bpmController = TextEditingController();
  final TextEditingController _numberofBarsController = TextEditingController();

  bool _dottedQuarterAccent = false;

  @override
  void initState() {
    _accentBeatsPerBarController.text = tempo?.accentBeatsPerBar.toString() ?? '1';
    _beatsPerBarController.text = tempo?.beatsPerBar.toString() ?? '4';
    _beatUnitController.text = tempo?.beatUnit.toString() ?? '4';
    _bpmController.text = tempo?.bpm.toString() ?? '';
    _dottedQuarterAccent = tempo?.dottedQuarterAccent ?? false;
    _numberofBarsController.text = tempo?.numberOfBars.toString() ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TempoBloc tempoBloc = Provider.of<TempoBloc>(context);
    final Track track = tempoBloc.track;

    String pageTitle = 'Tempo Info';
    if (track.title != null) {
      pageTitle = '${track.title} tempo';
    }

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () {
            final Tempo tempoToSave = tempo ?? Tempo();

            tempoToSave.accentBeatsPerBar =
                int.tryParse(_accentBeatsPerBarController.text) ?? 60;
            tempoToSave.beatsPerBar =
                int.tryParse(_beatsPerBarController.text) ?? 4;
            tempoToSave.beatUnit = int.tryParse(_beatUnitController.text) ?? 4;
            tempoToSave.bpm = double.tryParse(_bpmController.text) ?? 60;
            tempoToSave.dottedQuarterAccent = _dottedQuarterAccent;
            tempoToSave.numberOfBars =
                double.tryParse(_numberofBarsController.text) ?? 0;
            tempoToSave.trackId = track.id;

            if (tempo != null) {
              tempoBloc.update(tempoToSave);
            } else {
              tempoBloc.insert(tempoToSave);
            }

            Navigator.pop(context);
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
                title: TextField(controller: _bpmController),
                subtitle: const Text('BPM'),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: TextField(controller: _beatsPerBarController),
                subtitle: const Text('Beats Per Bar'),
              ),
              ListTile(
                leading: const Icon(Icons.title),
                title: TextField(controller: _beatUnitController),
                subtitle: const Text('Beat Unit'),
              ),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Dotted Quarter Accent'),
                value: _dottedQuarterAccent,
                onChanged: (bool? check) {
                  setState(() => _dottedQuarterAccent = check ?? false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.title),
                title: TextField(controller: _accentBeatsPerBarController),
                subtitle: const Text('Accent Beats Per Bar'),
              ),
              ListTile(
                leading: const Icon(Icons.title),
                title: TextField(controller: _numberofBarsController),
                subtitle: const Text('Number of Bars'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
