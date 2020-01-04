import 'dart:collection';

import 'package:in_the_pocket/bloc/setlist_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/setlist.g.m8.dart';

class EditSetListFormRouteArguments {
  EditSetListFormRouteArguments(
      this.setListBloc, this.setList, this.itemSelectionMap);
  SetListProxy setList;
  SetListBloc setListBloc;
  HashMap<SetListProxy, ItemSelection> itemSelectionMap;
}
