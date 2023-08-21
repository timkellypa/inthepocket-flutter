import 'dart:async';
import 'dart:collection';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/save_status.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/model_base.dart';
import 'package:in_the_pocket/repository/repository_base.dart';

abstract class ModelBlocBase<ModelType extends ModelBase,
    RepositoryType extends RepositoryBase<ModelType>> {
  ModelBlocBase() {
    selectedItemsController.sink.add(HashMap<String, ItemSelection>());

    fetch();
  }

  SaveStatus saveStatus = SaveStatus(0, 0.0, '');

  final StreamController<SaveStatus> _saveStatusController =
      StreamController<SaveStatus>.broadcast();

  Stream<SaveStatus> get saveStatusStream => _saveStatusController.stream;

  void updateSaveStatus(int total, double progress, String message) {
    saveStatus = SaveStatus(total, progress, message);
    _saveStatusController.sink.add(saveStatus);
  }

  List<ModelType> itemList = <ModelType>[];
  HashMap<String, ItemSelection> itemSelectionMap =
      HashMap<String, ItemSelection>();
  RepositoryType get repository;

  bool Function(ModelType)? get listFilter {
    return null;
  }

  String get listTitle {
    return 'Items';
  }

  StreamController<List<ModelType>> listController =
      StreamController<List<ModelType>>.broadcast();

  Stream<List<ModelType>> get items => listController.stream;

  StreamController<HashMap<String, ItemSelection>> selectedItemsController =
      StreamController<HashMap<String, ItemSelection>>.broadcast();

  Stream<HashMap<String, ItemSelection>> get selectedItems =>
      selectedItemsController.stream;

  bool isSelected(ModelType? model, int selectionTypes) {
    return (itemSelectionMap[model?.id ?? '']?.selectionType ?? 0) &
            selectionTypes ==
        selectionTypes;
  }

  void selectItem(ModelType? model, int selectionTypes,
      {bool doSync = true, bool allowMultiSelect = false}) {
    final String guid = model?.id ?? '';

    // unselect if all our selection types are currently active.
    if ((itemSelectionMap[guid]?.selectionType ?? 0) & selectionTypes ==
        selectionTypes) {
      unSelectItem(model, selectionTypes);
      if (doSync) {
        syncSelections();
      }
      return;
    }

    if (!allowMultiSelect) {
      unSelectAll(selectionTypes, doSync: false);
    }

    itemSelectionMap.putIfAbsent(guid, () => ItemSelection(0));
    itemSelectionMap[guid]!.selectionType |= selectionTypes;
    if (doSync) {
      syncSelections();
    }
  }

  void unSelectItem(ModelType? model, int selectionTypes,
      {bool doSync = true}) {
    final String guid = model?.id ?? '';
    itemSelectionMap.putIfAbsent(guid, () => ItemSelection(0));
    itemSelectionMap[guid]!.selectionType &= ~selectionTypes;

    if (itemSelectionMap[guid]!.selectionType == 0) {
      itemSelectionMap.remove(model);
    }

    if (doSync) {
      syncSelections();
    }
  }

  void unSelectAll(int selectionTypes, {bool doSync = true}) {
    final List<String> keysToRemove = <String>[];

    for (String key in itemSelectionMap.keys) {
      itemSelectionMap[key]!.selectionType &= ~selectionTypes;
      if (itemSelectionMap[key]!.selectionType == 0) {
        keysToRemove.add(key);
      }
    }

    keysToRemove.forEach(itemSelectionMap.remove);

    if (doSync) {
      syncSelections();
    }
  }

  List<ModelType?> getMatchingSelections(int selectionTypes) {
    final List<ModelType?> matchingSelections = <ModelType?>[];

    for (ModelType? item in itemList) {
      if (item == null) {
        continue;
      }
      if (itemSelectionMap.containsKey(item.id) &&
          itemSelectionMap[item.id]!.selectionType & selectionTypes > 0) {
        matchingSelections.add(item);
      }
    }

    // blank means new item was selected
    if (itemSelectionMap.containsKey('') &&
        itemSelectionMap['']!.selectionType & selectionTypes > 0) {
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
      {bool Function(ModelType)? filter}) async {
    filter ??= listFilter;
    final List<ModelType> itemListRetrieved =
        await repository.fetch(filter: filter);
    return itemListRetrieved;
  }

  void syncList(List<ModelType> newItemList) {
    itemList = newItemList;
    if (!listController.isClosed) {
      listController.sink.add(itemList);
    }
  }

  Future<List<ModelType>> fetch() async {
    final List<ModelType> newItemList = await getItemList();
    syncList(newItemList);
    return newItemList;
  }

  Future<void> insert(ModelType item);

  Future<void> update(ModelType item);

  Future<void> delete(ModelType item);

  void dispose() {
    listController.close();
    selectedItemsController.close();
  }

  void reset() {
    unSelectAll(SelectionType.all);
  }
}
