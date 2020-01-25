import 'dart:async';
import 'dart:collection';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/models/independent/model_base.dart';
import 'package:in_the_pocket/repository/repository_base.dart';

abstract class ModelBlocBase<ModelType extends ModelBase,
    RepositoryType extends RepositoryBase<ModelType>> {
  ModelBlocBase() {
    itemSelectionMap = HashMap<String, ItemSelection>();
    itemList = <ModelType>[];

    listController = StreamController<List<ModelType>>.broadcast();
    selectedItemsController =
        StreamController<HashMap<String, ItemSelection>>.broadcast();
    selectedItemsController.sink.add(HashMap<String, ItemSelection>());
    fetch();
  }

  List<ModelType> itemList;
  HashMap<String, ItemSelection> itemSelectionMap;
  RepositoryType get repository;

  Function get listFilter {
    return null;
  }

  String get listTitle {
    return 'Items';
  }

  StreamController<List<ModelType>> listController;

  Stream<List<ModelType>> get items => listController.stream;

  StreamController<HashMap<String, ItemSelection>> selectedItemsController;

  Stream<HashMap<String, ItemSelection>> get selectedItems =>
      selectedItemsController.stream;

  void selectItem(ModelType model, int selectionTypes, {bool doSync = true}) {
    final String guid = model?.guid ?? '';
    itemSelectionMap.putIfAbsent(guid, () => ItemSelection(0));
    itemSelectionMap[guid].selectionType |= selectionTypes;
    if (doSync) {
      syncSelections();
    }
  }

  void unSelectItem(ModelType model, int selectionTypes, {bool doSync = true}) {
    final String guid = model?.guid ?? '';
    itemSelectionMap.putIfAbsent(guid, () => ItemSelection(0));
    itemSelectionMap[guid].selectionType &= ~selectionTypes;

    if (itemSelectionMap[guid].selectionType == 0) {
      itemSelectionMap.remove(model);
    }

    if (doSync) {
      syncSelections();
    }
  }

  void unSelectAll(int selectionTypes, {bool doSync = true}) {
    final List<String> keysToRemove = <String>[];

    for (String key in itemSelectionMap.keys) {
      itemSelectionMap[key].selectionType &= ~selectionTypes;
      if (itemSelectionMap[key].selectionType == 0) {
        keysToRemove.add(key);
      }
    }

    keysToRemove.forEach(itemSelectionMap.remove);

    if (doSync) {
      syncSelections();
    }
  }

  List<ModelType> getMatchingSelections(int selectionTypes) {
    final List<ModelType> matchingSelections = <ModelType>[];

    for (ModelType item in itemList) {
      if (itemSelectionMap.containsKey(item.guid) &&
          itemSelectionMap[item.guid].selectionType & selectionTypes > 0) {
        matchingSelections.add(item);
      }
    }

    // blank means new item was selected
    if (itemSelectionMap.containsKey('') &&
        itemSelectionMap[''].selectionType & selectionTypes > 0) {
      matchingSelections.add(null);
    }

    return matchingSelections;
  }

  void syncSelections() {
    if (!selectedItemsController.isClosed) {
      selectedItemsController.sink.add(itemSelectionMap);
    }
  }

  Future<List<ModelType>> getItemList(
      {Function filter, bool update = true}) async {
    filter ??= listFilter;
    final List<ModelType> itemListRetrieved =
        await repository.fetch(filter: filter);
    if (update) {
      itemList = itemListRetrieved;
    }
    return itemListRetrieved;
  }

  Future<List<ModelType>> fetch() async {
    await getItemList();
    if (!listController.isClosed) {
      listController.sink.add(itemList);
    }
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
