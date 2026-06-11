import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
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

  ModelType? pendingNewItem;

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

  Future<ModelType> buildNewItem();

  Future<void> startAddNewItem() async {
    pendingNewItem = await buildNewItem();
    selectItem(pendingNewItem!, SelectionType.add);
  }

  bool isSelected(ModelType? model, int selectionTypes) {
    return (itemSelectionMap[model?.id ?? '']?.selectionType ?? 0) &
            selectionTypes ==
        selectionTypes;
  }

  ScrollController scrollController = ScrollController();

  /// Select an item.
  /// [selectionTypes] is a bitmask of types
  /// [allowMultiSelect] can be true only if
  /// [doSync] verifies whether or not we are supposed to re-sync this list change.
  /// [allowSelectionToggle] allows selecting of an already-selected item to unselect it
  /// (like a checkbox)
  /// [verifyItemExists] will exit silently if the newly selected item is not in our list, or is
  /// not the newly added pending model (during an add).  We will set this to false for things like
  /// list disabled selections, which are set prior to the list loading.
  void selectItem(ModelType model, int selectionTypes,
      {bool doSync = true,
      bool verifyItemExists = true,
      bool allowMultiSelect = false,
      bool allowSelectionToggle = true}) {
    final String guid = model.id!;

    final bool itemExistsOrCheckSkipped = !verifyItemExists ||
        (itemList.indexWhere((ModelType item) => item.id == model.id) != -1 ||
            model.id == pendingNewItem?.id);

    // Only proceed if our item is found in the list, or if we're explicitly skipping that.
    if (!itemExistsOrCheckSkipped) {
      return;
    }
    // unselect if all our selection types are currently active.
    if ((itemSelectionMap[guid]?.selectionType ?? 0) & selectionTypes ==
            selectionTypes &&
        allowSelectionToggle) {
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
      if (guid == pendingNewItem?.id) {
        pendingNewItem = null;
      }
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
        if (key == pendingNewItem?.id) {
          pendingNewItem = null;
        }
      }
    }

    keysToRemove.forEach(itemSelectionMap.remove);

    if (doSync) {
      syncSelections();
    }
  }

  List<ModelType?> getMatchingSelections(int selectionTypes) {
    final List<ModelType?> matchingSelections = <ModelType?>[];

    for (ModelType? item in <ModelType?>[...itemList, pendingNewItem]) {
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

  ModelType? get firstSelectedItem =>
      getMatchingSelections(SelectionType.selected).firstOrNull;

  ModelType? get itemInEditMode =>
      getMatchingSelections(SelectionType.editing + SelectionType.add)
          .firstOrNull;

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

  Future<void> upsert(ModelType item);

  Future<void> delete(ModelType item);

  void dispose() {
    listController.close();
    selectedItemsController.close();
    scrollController.dispose();
  }

  void reset() {
    unSelectAll(SelectionType.all);
  }
}
