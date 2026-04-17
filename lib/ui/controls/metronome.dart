import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/standalone_metronome_bloc.dart';
import 'package:in_the_pocket/classes/click_info.dart';
import 'package:in_the_pocket/ui/components/click_state_display.dart';
import 'package:in_the_pocket/ui/haptics/MetronomeBuzzer.dart';
import 'package:in_the_pocket/ui/listeners/MetronomeClickPlayer.dart';
import 'package:led_bulb_indicator/led_bulb_indicator.dart';
import 'package:provider/provider.dart';
import 'package:wheel_picker/wheel_picker.dart';

class MetronomeControl extends StatefulWidget {
  const MetronomeControl();

  @override
  State<StatefulWidget> createState() {
    return MetronomeControlState();
  }
}

class MetronomeControlState extends State<MetronomeControl> {
  MetronomeBuzzer? buzzer;
  MetronomeClickPlayer? clickPlayer;

  @override
  Widget build(BuildContext context) {
    final StandaloneMetronomeBloc metronomeBloc =
        Provider.of<StandaloneMetronomeBloc>(context);

    buzzer?.stopListening();
    buzzer = MetronomeBuzzer(clickStateStream: metronomeBloc.clickStateStream);
    buzzer!.listen();

    clickPlayer?.stopListening();
    clickPlayer =
        MetronomeClickPlayer(clickStateStream: metronomeBloc.clickStateStream);
    clickPlayer!.listen();

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 10,
      children: <Widget>[
        StreamBuilder<ClickState>(
            stream: metronomeBloc.clickStateStream,
            initialData: ClickState(
                count: ClickInfo.SILENCE_COUNT,
                beatsPerBar: metronomeBloc.beatsPerBar),
            builder:
                (BuildContext context, AsyncSnapshot<ClickState> clickState) {
              return ClickStateDisplay(clickState: clickState.data!);
            }),
        Padding(
            padding: const EdgeInsetsGeometry.fromLTRB(30, 0, 30, 0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Column(spacing: 20, children: <Widget>[
                    Column(children: <Widget>[
                      const Text('Counts:'),
                      DropdownMenu<int>(
                          width: 100,
                          dropdownMenuEntries: const <DropdownMenuEntry<int>>[
                            DropdownMenuEntry<int>(value: 1, label: '1'),
                            DropdownMenuEntry<int>(value: 2, label: '2'),
                            DropdownMenuEntry<int>(value: 3, label: '3'),
                            DropdownMenuEntry<int>(value: 4, label: '4'),
                            DropdownMenuEntry<int>(value: 5, label: '5'),
                            DropdownMenuEntry<int>(value: 6, label: '6'),
                            DropdownMenuEntry<int>(value: 7, label: '7'),
                            DropdownMenuEntry<int>(value: 8, label: '8'),
                          ],
                          initialSelection: metronomeBloc.beatsPerBar,
                          onSelected: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                metronomeBloc.beatsPerBar = newValue;
                              });
                            }
                          })
                    ]),
                  ]),
                  Column(
                    children: <Widget>[
                      const Text('Accents:'),
                      DropdownMenu<int>(
                          width: 100,
                          dropdownMenuEntries: const <DropdownMenuEntry<int>>[
                            DropdownMenuEntry<int>(value: 1, label: '1'),
                            DropdownMenuEntry<int>(value: 2, label: '2'),
                            DropdownMenuEntry<int>(value: 3, label: '3'),
                            DropdownMenuEntry<int>(value: 4, label: '4'),
                          ],
                          initialSelection: metronomeBloc.accentBeatsPerBar,
                          onSelected: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                metronomeBloc.accentBeatsPerBar = newValue;
                              });
                            }
                          })
                    ],
                  ),
                ])),
        Row(
            children: <Widget>[
              // Hidden identical BPM text to keep wheel picker in center.
              const Visibility(
                visible: false,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Text('BPM', style: TextStyle(fontSize: 20)),
              ),
              Container(
                  height: 200,
                  width: 100,
                  child: WheelPicker(
                      key: Key(metronomeBloc.bpmIndex.toString()),
                      builder: (BuildContext context, int index) => Text(
                          '${index + 20}',
                          style: const TextStyle(fontSize: 30)),
                      itemCount: 280,
                      onIndexChanged:
                          (int index, WheelPickerInteractionType type) {
                        setState(() {
                          metronomeBloc.bpmIndex = index;
                        });
                      },
                      initialIndex: metronomeBloc.bpmIndex,
                      looping: false,
                      style: const WheelPickerStyle(
                        itemExtent: 40, // Text height
                        squeeze: 1.25,
                        diameterRatio: .8,
                        surroundingOpacity: .25,
                        magnification: 1.2,
                      ))),
              const Text('BPM', style: TextStyle(fontSize: 20))
            ],
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center),
        Padding(
            padding: const EdgeInsetsGeometry.fromLTRB(30, 0, 30, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                MaterialButton(
                  onPressed: () {
                    setState(() {
                      metronomeBloc.handleTap();
                    });
                  },
                  child: const Text('Tap', style: TextStyle(fontSize: 16)),
                  minWidth: 150,
                  height: 60,
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                ),
                MaterialButton(
                  onPressed: () {
                    setState(() {
                      if (metronomeBloc.isClicking) {
                        metronomeBloc.handlePause();
                      } else {
                        metronomeBloc.handlePlay();
                      }
                    });
                  },
                  minWidth: 150,
                  height: 60,
                  child: Icon(metronomeBloc.isClicking
                      ? Icons.pause
                      : Icons.play_arrow),
                  color: Theme.of(context).colorScheme.primary,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ],
            ))
      ],
    ));
  }

  @override
  void dispose() {
    super.dispose();
    buzzer?.stopListening();
    clickPlayer?.dispose();
  }
}
