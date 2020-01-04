import 'dart:async';
import 'dart:collection';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/repository/repository_base.dart';

abstract class ModelBlocBase<ModelType,
    RepositoryType extends RepositoryBase<ModelType>> {
  ModelBlocBase() {
    selectedItemsController.sink.add(HashMap<ModelType, ItemSelection>());
    fetch();
  }

  RepositoryType get repository;

  Function get listFilter {
    return null;
  }

  String get listTitle {
    return 'Items';
  }

  final StreamController<List<ModelType>> listController =
      StreamController<List<ModelType>>.broadcast();

  Stream<List<ModelType>> get items => listController.stream;

  final StreamController<HashMap<ModelType, ItemSelection>>
      selectedItemsController =
      StreamController<HashMap<ModelType, ItemSelection>>.broadcast();

  Stream<HashMap<ModelType, ItemSelection>> get selectedItems =>
      selectedItemsController.stream;

  void selectItem(HashMap<ModelType, ItemSelection> map, ModelType model,
      int selectionTypes,
      {bool doSync = true}) {
    map.putIfAbsent(model, () => ItemSelection(0));
    map[model].selectionType |= selectionTypes;
    if (doSync) {
      syncSelections(map);
    }
  }

  void unSelectItem(HashMap<ModelType, ItemSelection> map, ModelType model,
      int selectionTypes,
      {bool doSync = true}) {
    map.putIfAbsent(model, () => ItemSelection(0));
    map[model].selectionType &= ~selectionTypes;

    if (map[model].selectionType == 0) {
      map.remove(model);
    }

    if (doSync) {
      syncSelections(map);
    }
  }

  Future<void> syncSelections(HashMap<ModelType, ItemSelection> map) async {
    selectedItemsController.sink.add(map);
  }

  Future<List<ModelType>> getItemList({Function filter}) async {
    filter ??= listFilter;
    return await repository.fetch(filter: filter);
  }

  Future<List<ModelType>> fetch() async {
    final List<ModelType> itemList = await getItemList();
    listController.sink.add(itemList);
    return itemList;
  }

  Future<void> insert(ModelType item);

  Future<void> update(ModelType item);

  Future<void> delete(ModelType item);

  void dispose() {
    listController.close();
    selectedItemsController.close();
  }
}
