import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
import 'package:in_the_pocket/bloc/setlist_bloc.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';
import 'package:in_the_pocket/ui/components/lists/model_list_base.dart';
import 'package:in_the_pocket/ui/components/cards/setlist_card.dart';
import 'package:provider/provider.dart';

class SetListList<SetListCardType extends SetListCard>
    extends ModelListBase<SetListProxy, SetListCardType> {
  const SetListList(CardCreator<SetListCardType, SetListProxy> creator)
      : super(creator);

  @override
  String get addItemText => 'Start Adding Setlists...';

  @override
  ModelBlocBase<dynamic, dynamic> getBloc(BuildContext context) {
    return Provider.of<SetListBloc>(context);
  }
}
