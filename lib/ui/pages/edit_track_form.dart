// ignore_for_file: experimental_member_use

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:in_the_pocket/bloc/tempo_bloc.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/cards/tempo_card_sud.dart';
import 'package:in_the_pocket/ui/components/lists/tempo_list.dart';
import 'package:in_the_pocket/ui/controls/smart_duration_formatter.dart';
import 'package:in_the_pocket/ui/navigation/edit_tempo_form_route_arguments.dart';
import 'package:in_the_pocket/utilities/text_editor_utils.dart';
import 'package:provider/provider.dart';

import '../components/new_item_button.dart';
import '../navigation/application_router.dart';

// Enough height to show 2 tempos without scrolling,
// but leave plenty of real estate for notes.
const double tempoListHeight = 180;

class EditTrackForm extends StatefulWidget {
  const EditTrackForm(this.setlist, {this.setlistTrack});
  final SetlistTrack? setlistTrack;
  final Setlist setlist;

  @override
  State<StatefulWidget> createState() {
    return EditSetlistFormState(setlist, setlistTrack);
  }
}

class EditSetlistFormState extends State<EditTrackForm> {
  EditSetlistFormState(this.setlist, this.setlistTrack);

  Setlist setlist;
  SetlistTrack? setlistTrack;
  late TempoBloc tempoBloc;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  late QuillController _notesController;
  final Set<String> _cachedImagePaths = <String>{};

  final GlobalKey _editorContainerKey =
      GlobalKey(debugLabel: 'editorContainer');

  late ScrollController _formScrollController = ScrollController();

  late ScrollController _editorScrollController;
  late FocusNode _editorFocusNode;

  @override
  void initState() {
    setlistTrack ??= SetlistTrack();
    setlistTrack!.plTrack ??= Track();
    _titleController.text = setlistTrack!.plTrack!.title ?? '';
    _artistController.text = setlistTrack!.plTrack!.artist ?? '';
    _durationController.text = SmartDurationFormatter.durationToString(
        setlistTrack!.plTrack!.duration ?? 0);

    final Document document = getQuillDocumentFromContent(setlistTrack?.notes);

    _notesController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(
            enableExternalRichPaste: true,
            onImagePaste: (Uint8List imageBytes) async {
              final String path = await downloadImageAsset(imageBytes, 'png');
              _cachedImagePaths.add(path);
              return path;
            },
            onGifPaste: (Uint8List imageBytes) async {
              final String path = await downloadImageAsset(imageBytes, 'gif');
              _cachedImagePaths.add(path);
              return path;
            }),
      ),
    );

    _cachedImagePaths
        .addAll(getImagePathsInDocument(_notesController.document));

    tempoBloc = TempoBloc(setlistTrack!.plTrack!);

    tempoBloc.selectedItems.listen(itemSelectionsChanged);

    _formScrollController = ScrollController();

    _editorScrollController = getStandardEditorScrollController();
    _editorFocusNode =
        getStandardEditorFocusNode(_editorContainerKey, _formScrollController);
    super.initState();
  }

  void itemSelectionsChanged(HashMap<String, ItemSelection> itemSelectionMap) {
    final List<Tempo?> selectedItems = tempoBloc
        .getMatchingSelections(SelectionType.editing + SelectionType.add);

    if (selectedItems.isEmpty) {
      return;
    }

    final Tempo? selectedTempo = selectedItems.first;
    final int selectionType =
        itemSelectionMap[selectedTempo?.id ?? '']?.selectionType ??
            SelectionType.add;
    if (selectionType & (SelectionType.editing + SelectionType.add) > 0) {
      Navigator.pushNamed(
        context,
        ApplicationRouter.ROUTE_EDIT_TEMPO_FORM,
        arguments: EditTempoFormRouteArguments(
          tempoBloc,
          selectedTempo,
          itemSelectionMap,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TrackBloc trackBloc = Provider.of<TrackBloc>(context);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Track Info'), actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () async {
            await cleanupOrphanedImagesFromDocument(
                _notesController.document, _cachedImagePaths);

            final SetlistTrack setlistTrackToSave =
                setlistTrack ?? SetlistTrack();

            setlistTrackToSave.setlistId = setlist.id;

            setlistTrackToSave.plTrack ??= Track();

            setlistTrackToSave.plTrack!.title = _titleController.value.text;

            setlistTrackToSave.plTrack!.artist = _artistController.value.text;

            setlistTrackToSave.plTrack!.duration =
                SmartDurationFormatter.stringToDuration(
                    _durationController.value.text);

            setlistTrackToSave.notes =
                jsonEncode(_notesController.document.toDelta().toJson());

            if (setlistTrackToSave.plTrack!.title!.isNotEmpty) {
              if (setlistTrack?.id != null) {
                await trackBloc.update(setlistTrackToSave);
              } else {
                await trackBloc.insert(setlistTrackToSave);
              }

              Navigator.pop(context);
            }
          },
        )
      ]),
      body: GestureDetector(
          behavior: HitTestBehavior
              .translucent, // Catches taps even on transparent areas
          onTap: () {
            // Removes focus from any currently focused widget
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Builder(
            builder: (BuildContext context) {
              final double keyboardHeight =
                  MediaQuery.of(context).viewInsets.bottom;

              return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  controller: _formScrollController,
                  physics: keyboardHeight > 0
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  child: Padding(
                      padding: EdgeInsets.only(bottom: keyboardHeight),
                      child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight: constraints.maxHeight,
                              minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(
                              child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.title),
                                title: TextField(controller: _titleController),
                                subtitle: const Text('Title'),
                              ),
                              ListTile(
                                leading: const Icon(Icons.person),
                                title: TextField(controller: _artistController),
                                subtitle: const Text('Artist'),
                              ),
                              ListTile(
                                leading: const Icon(Icons.timer),
                                title: TextField(
                                    controller: _durationController,
                                    inputFormatters: <TextInputFormatter>[
                                      SmartDurationFormatter()
                                    ],
                                    keyboardType: TextInputType.number),
                                subtitle: const Text('Duration (mm:ss)'),
                              ),
                              QuillSimpleToolbar(
                                  controller: _notesController,
                                  config: standardToolbarConfig),
                              Expanded(
                                  child: Container(
                                key: _editorContainerKey,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                    width: 0.25,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                margin: const EdgeInsets.all(8.0),
                                child: QuillEditor(
                                  focusNode: _editorFocusNode,
                                  scrollController: _editorScrollController,
                                  controller: _notesController,
                                  config: QuillEditorConfig(
                                    placeholder: 'Notes',
                                    padding: const EdgeInsets.all(16),
                                    embedBuilders: <EmbedBuilder>[
                                      ...FlutterQuillEmbeds.editorBuilders(
                                        imageEmbedConfig:
                                            standardImageEmbedConfig,
                                        videoEmbedConfig:
                                            standardVideoEmbedConfig,
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                              Container(
                                height: tempoListHeight,
                                child: buildTempoList(),
                              ),
                            ],
                          )))),
                );
              });
            },
          )),
      floatingActionButton: NewItemButton<Tempo>(modelBloc: tempoBloc),
    );
  }

  Widget buildTempoList() {
    return Provider<TempoBloc>(
      create: (BuildContext context) => tempoBloc,
      child: TempoList<TempoCardSUD>(
          (Tempo a, HashMap<String, ItemSelection> b) => TempoCardSUD(a, b)),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _artistController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
