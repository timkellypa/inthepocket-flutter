import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
import 'package:in_the_pocket/bloc/tempo_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/providers/get_song_bpm_provider.dart';
import 'package:in_the_pocket/ui/components/cards/tempo_card.dart';
import 'package:in_the_pocket/ui/components/lists/model_list_base.dart';
import 'package:provider/provider.dart';

class TempoList<CardType extends TempoCard>
    extends ModelListBase<Tempo, CardType> {
  const TempoList(
      CardType Function(Tempo, HashMap<String, ItemSelection>) creator)
      : super(creator);
  @override
  String get addItemText => 'Fetch Tempo From Provider';
  @override
  Icon get addItemIcon => const Icon(Icons.add_to_queue);
  @override
  Function(BuildContext)? get addItemAction => (BuildContext context) async {
        final TempoBloc tempoBloc =
            Provider.of<TempoBloc>(context, listen: false);
        final Tempo? tempo =
            await GetSongBpmProvider().getSongTempo(tempoBloc.track);

        if (tempo == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('No tempo information found for this track.')));
          return;
        }
        tempoBloc.insert(tempo);
      };

  @override
  ModelBlocBase<Tempo, dynamic> getBloc(BuildContext context) {
    return Provider.of<TempoBloc>(context);
  }
}
