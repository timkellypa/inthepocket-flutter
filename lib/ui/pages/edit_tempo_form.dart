import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/standalone_metronome_bloc.dart';
import 'package:in_the_pocket/bloc/tempo_bloc.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/controls/metronome.dart';
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
  EditTempoFormState(this.tempo) {
    beatUnitValueMap = beatUnitEntries.asMap().map(
        (_, DropdownMenuEntry<int> entry) =>
            MapEntry<int, String>(entry.value, entry.label));

    beatUnitLabelMap = beatUnitEntries.asMap().map(
        (_, DropdownMenuEntry<int> entry) =>
            MapEntry<String, int>(entry.label, entry.value));
  }

  Tempo? tempo;
  final TextEditingController _accentBeatsPerBarController =
      TextEditingController();
  final TextEditingController _beatsPerBarController = TextEditingController();
  final TextEditingController _beatUnitController = TextEditingController();
  final TextEditingController _bpmController = TextEditingController();
  final TextEditingController _numberofBarsController = TextEditingController();

  final List<DropdownMenuEntry<int>> beatUnitEntries =
      const <DropdownMenuEntry<int>>[
    DropdownMenuEntry<int>(value: 2, label: '1/2'),
    DropdownMenuEntry<int>(value: 4, label: '1/4'),
    DropdownMenuEntry<int>(value: 8, label: '1/8'),
    DropdownMenuEntry<int>(value: 16, label: '1/16'),
  ];

  late Map<int, String> beatUnitValueMap;
  late Map<String, int> beatUnitLabelMap;

  @override
  void initState() {
    _accentBeatsPerBarController.text =
        tempo?.accentBeatsPerBar.toString() ?? '1';
    _beatsPerBarController.text = tempo?.beatsPerBar.toString() ?? '4';
    _beatUnitController.text = beatUnitValueMap[tempo?.beatUnit ?? 4] ?? '1/4';
    _bpmController.text = tempo?.bpm.toString() ?? '';

    if (tempo?.numberOfBars == 0 || tempo?.numberOfBars == null) {
      _numberofBarsController.text = '';
    } else {
      _numberofBarsController.text = tempo?.numberOfBars.toString() ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TempoBloc tempoBloc = Provider.of<TempoBloc>(context);
    final Track track = tempoBloc.track;
    final StandaloneMetronomeBloc metronomeBloc =
        Provider.of<StandaloneMetronomeBloc>(context);
    metronomeBloc.accentBeatsPerBar = tempo?.accentBeatsPerBar ?? 1;
    metronomeBloc.beatsPerBar = tempo?.beatsPerBar ?? 4;
    metronomeBloc.beatUnit = tempo?.beatUnit ?? 4;
    metronomeBloc.bpm = (tempo?.bpm ?? 60).round();

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

            tempoToSave.accentBeatsPerBar = metronomeBloc.accentBeatsPerBar;
            tempoToSave.beatsPerBar = metronomeBloc.beatsPerBar;
            tempoToSave.bpm = metronomeBloc.bpm.toDouble();

            // Hardcode this to false.  We are just using individual pulses for clicks all the time,
            // so dotted quarter BPM processing for 6/8 isn't relevant.
            tempoToSave.dottedQuarterAccent = false;

            tempoToSave.beatUnit =
                beatUnitLabelMap[_beatUnitController.text] ?? 4;
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
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          children: <Widget>[
            const MetronomeControl(),
            ListTile(
              leading: const Icon(Icons.title),
              title: DropdownMenu<int>(
                dropdownMenuEntries: beatUnitEntries,
                controller: _beatUnitController,
              ),
              subtitle: const Text('Beat Unit'),
            ),
            ListTile(
              leading: const Icon(Icons.title),
              title: TextField(controller: _numberofBarsController),
              subtitle: const Text('Number of Bars'),
            ),
          ],
        ),
      )),
    );
  }
}
