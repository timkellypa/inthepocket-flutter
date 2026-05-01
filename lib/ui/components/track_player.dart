import 'dart:collection';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/click_info.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/click_state_display.dart';
import 'package:in_the_pocket/ui/components/measure_size.dart';
import 'package:in_the_pocket/ui/haptics/MetronomeBuzzer.dart';
import 'package:in_the_pocket/utilities/text_editor_utils.dart';
import 'package:provider/provider.dart';

class TrackPlayer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TrackPlayerState();
  }
}

class TrackPlayerState extends State<TrackPlayer> {
  bool _notesExpanded = false;
  double? _notesContentHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  final ScrollController _scrollController =
      getStandardEditorScrollController();

  FocusNode get _focusNode => getStandardEditorFocusNode(null, null);

  MetronomeBuzzer? buzzer;

  @override
  Widget build(BuildContext context) {
    final TrackBloc trackBloc = Provider.of<TrackBloc>(context);

    return Container(
      child: StreamBuilder<List<SetlistTrack>>(
        stream: trackBloc.items,
        builder: (BuildContext context,
            AsyncSnapshot<List<SetlistTrack>> tracksSnapshot) {
          // change in list should cause us to restart the track audio service
          if (!tracksSnapshot.hasData) {
            return Container();
          }

          return StreamBuilder<HashMap<String, ItemSelection>>(
            stream: trackBloc.selectedItems,
            initialData: HashMap<String, ItemSelection>(),
            builder: (BuildContext innerContext,
                AsyncSnapshot<HashMap<String, ItemSelection>>
                    selectionsSnapshot) {
              final List<SetlistTrack?> selectedSetlistTracks =
                  trackBloc.getMatchingSelections(SelectionType.selected);
              final SetlistTrack? selectedSetlistTrack =
                  selectedSetlistTracks.isNotEmpty
                      ? selectedSetlistTracks.first
                      : null;
              if (selectedSetlistTrack == null) {
                return Container(width: 0.0, height: 0.0);
              }

              final Document notesDocument =
                  getQuillDocumentFromContent(selectedSetlistTrack.notes);

              final QuillController notesController = QuillController(
                  document: notesDocument,
                  selection: const TextSelection.collapsed(offset: 0),
                  readOnly: true);

              return Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(selectedSetlistTrack.plTrack!.title!,
                        style: const TextStyle(fontSize: 26),
                        overflow: TextOverflow.ellipsis),
                    if (selectedSetlistTrack.plTrack!.artist != null &&
                        selectedSetlistTrack.plTrack!.artist!.isNotEmpty)
                      Text(selectedSetlistTrack.plTrack!.artist ?? '',
                          style: const TextStyle(
                              fontSize: 16, fontStyle: FontStyle.italic),
                          overflow: TextOverflow.ellipsis),
                    if (!notesDocument.isEmpty())
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 0.25,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          margin: const EdgeInsets.all(8),
                          child: Stack(children: <Widget>[
                            Column(
                              children: <Widget>[
                                LayoutBuilder(
                                  builder: (BuildContext context,
                                      BoxConstraints constraints) {
                                    return Container(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: SizedBox(
                                          height: _notesExpanded
                                              ? 400
                                              : min(_notesContentHeight ?? 150,
                                                  150),
                                          child: Stack(
                                            children: <Widget>[
                                              Scrollbar(
                                                controller: _scrollController,
                                                thumbVisibility: _notesExpanded,
                                                child: SingleChildScrollView(
                                                  controller: _scrollController,
                                                  physics: _notesExpanded
                                                      ? const AlwaysScrollableScrollPhysics()
                                                      : const NeverScrollableScrollPhysics(),
                                                  child: MeasureSize(
                                                      onChange: (Size size) {
                                                        setState(() {
                                                          _notesContentHeight =
                                                              size.height;
                                                        });
                                                      },
                                                      child: AbsorbPointer(
                                                          child: QuillEditor(
                                                        focusNode: _focusNode,
                                                        scrollController:
                                                            _scrollController,
                                                        controller:
                                                            notesController,
                                                        config:
                                                            QuillEditorConfig(
                                                          showCursor: false,
                                                          readOnlyMouseCursor:
                                                              SystemMouseCursors
                                                                  .basic,
                                                          scrollable: false,
                                                          padding:
                                                              EdgeInsets.only(
                                                            left: 16,
                                                            right: 16,
                                                            top: 16,
                                                            bottom:
                                                                _notesExpanded
                                                                    ? 80
                                                                    : 16,
                                                          ),
                                                          embedBuilders: <EmbedBuilder>[
                                                            ...FlutterQuillEmbeds
                                                                .editorBuilders(
                                                              imageEmbedConfig:
                                                                  standardImageEmbedConfig,
                                                              videoEmbedConfig:
                                                                  standardVideoEmbedConfig,
                                                            ),
                                                          ],
                                                        ),
                                                      ))),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            if (_notesContentHeight != null &&
                                _notesContentHeight! > 150)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    if (_notesExpanded) {
                                      _scrollController.animateTo(
                                        0,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                    setState(() {
                                      _notesExpanded = !_notesExpanded;
                                    });
                                  },
                                  child: Container(
                                    height: 44,
                                    margin:
                                        const EdgeInsets.fromLTRB(4, 0, 4, 0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: <Color>[
                                          Theme.of(context)
                                              .scaffoldBackgroundColor
                                              .withValues(alpha: 0),
                                          Theme.of(context)
                                              .scaffoldBackgroundColor
                                              .withValues(alpha: 1),
                                        ],
                                        stops: const <double>[0.0, 0.35],
                                      ),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                _notesExpanded
                                                    ? 'Less'
                                                    : 'More',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                _notesExpanded
                                                    ? Icons.expand_less
                                                    : Icons.expand_more,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ])),
                    if (selectedSetlistTrack.plTrack!.plTempos?.isNotEmpty ??
                        false)
                      StreamBuilder<ClickState>(
                          stream: trackBloc.indicatorStateBloc.clickStateStream,
                          initialData: ClickState(count: 0),
                          builder: (BuildContext context,
                              AsyncSnapshot<ClickState> clickState) {
                            return ClickStateDisplay(
                                clickState: clickState.data!);
                          })
                    else
                      Center(
                          child: TextButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Add tempos to enable click track'),
                        onPressed: () {
                          trackBloc.selectItem(
                              selectedSetlistTrack, SelectionType.editing);
                        },
                      )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          iconSize: 90,
                          icon: const Icon(Icons.skip_previous),
                          onPressed: trackBloc.isFirstSelected
                              ? null
                              : () {
                                  trackBloc.skipToPrevious();
                                },
                        ),
                        StreamBuilder<PlaybackState>(
                          stream: trackBloc.audioPlaybackStream,
                          initialData: trackBloc.audioPlaybackState,
                          builder: (BuildContext context,
                              AsyncSnapshot<PlaybackState>
                                  playbackStateSnapshot) {
                            Icon toggleIcon;

                            if (playbackStateSnapshot.data!.playing ||
                                playbackStateSnapshot.data!.processingState ==
                                    AudioProcessingState.buffering) {
                              toggleIcon = const Icon(Icons.pause);
                            } else {
                              toggleIcon = const Icon(Icons.headset);
                            }

                            bool disabled = false;
                            if (selectedSetlistTrack.plTrack!.plTempos ==
                                    null ||
                                selectedSetlistTrack
                                    .plTrack!.plTempos!.isEmpty) {
                              disabled = true;
                            }

                            return IconButton(
                                iconSize: 90,
                                icon: toggleIcon,
                                onPressed: disabled
                                    ? null
                                    : () {
                                        trackBloc.audioClick();
                                      });
                          },
                        ),
                        IconButton(
                          iconSize: 90,
                          icon: const Icon(Icons.skip_next),
                          onPressed: trackBloc.isLastSelected
                              ? null
                              : () {
                                  trackBloc.skipToNext();
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
  }
}
