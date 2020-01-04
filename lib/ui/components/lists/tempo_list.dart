import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
import 'package:in_the_pocket/bloc/tempo_bloc.dart';
import 'package:in_the_pocket/models/independent/tempo.g.m8.dart';
import 'package:in_the_pocket/ui/components/cards/tempo_card.dart';
import 'package:in_the_pocket/ui/components/lists/model_list_base.dart';
import 'package:provider/provider.dart';

class TempoList<CardType extends TempoCard>
    extends ModelListBase<TempoProxy, CardType> {
  const TempoList(Function creator) : super(creator);
  @override
  String get addItemText => 'No tempos available';

  @override
  ModelBlocBase<dynamic, dynamic> getBloc(BuildContext context) {
    return Provider.of<TempoBloc>(context);
  }
}
