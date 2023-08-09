import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/bloc/model_bloc_base.dart';
import 'package:in_the_pocket/bloc/setlist_bloc.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/setlist_card.dart';
import 'package:in_the_pocket/ui/components/lists/model_list_base.dart';
import 'package:provider/provider.dart';

class SetlistList<SetlistCardType extends SetlistCard>
    extends ModelListBase<Setlist, SetlistCardType> {
  const SetlistList(CardCreator<SetlistCardType, Setlist> creator)
      : super(creator);

  @override
  String get addItemText => 'Start Adding Setlists...';

  @override
  ModelBlocBase<Setlist, dynamic> getBloc(BuildContext context) {
    return Provider.of<SetlistBloc>(context);
  }
}
