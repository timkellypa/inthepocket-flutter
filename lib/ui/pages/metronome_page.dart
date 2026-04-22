import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/standalone_metronome_bloc.dart';
import 'package:in_the_pocket/ui/controls/metronome.dart';
import 'package:provider/provider.dart';

const double DEFAULT_BPM = 120.0;
const double DEFAULT_TIME_SIGNATURE_TOP = 4.0;
const double DEFAULT_TIME_SIGNATURE_BOTTOM = 4.0;

class MetronomePage extends StatefulWidget {
  const MetronomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MetronomePageState();
  }
}

class MetronomePageState extends State<MetronomePage> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey(debugLabel: 'scaffoldKey');
  StandaloneMetronomeBloc? metronomeBloc;

  @override
  void initState() {
    super.initState();
    metronomeBloc = StandaloneMetronomeBloc();
  }

  @override
  Widget build(BuildContext context) {
    final StandaloneMetronomeBloc metronomeBloc = this.metronomeBloc!;

    return Scaffold(
        key: scaffoldKey,
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Metronome'),
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding:
                    const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 2.0),
                child: Center(
                  child: Provider<StandaloneMetronomeBloc>(
                    create: (_) => metronomeBloc,
                    child: const MetronomeControl(),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    metronomeBloc?.dispose();
    super.dispose();
  }
}
