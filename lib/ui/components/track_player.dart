import 'dart:collection';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_svg/svg.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/click_info.dart';
import 'package:in_the_pocket/classes/item_selection.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/model/setlistdb.dart';
import 'package:in_the_pocket/ui/components/bottom_panel_handle.dart';
import 'package:in_the_pocket/ui/components/click_state_display.dart';
import 'package:in_the_pocket/ui/components/measure_size.dart';
import 'package:in_the_pocket/utilities/text_editor_utils.dart';
import 'package:provider/provider.dart';

class TrackPlayer extends StatefulWidget {
  const TrackPlayer(
      {this.panelExpanded = false, this.minHeight = 200, this.maxHeight = 600});
  final bool panelExpanded;
  final double minHeight;
  final double maxHeight;

  @override
  State<StatefulWidget> createState() {
    return TrackPlayerState();
  }
}

class TrackPlayerState extends State<TrackPlayer> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  final ScrollController _scrollController =
      getStandardEditorScrollController();

  FocusNode get _focusNode => getStandardEditorFocusNode(null, null);
  double _footerSize = 80;
  double _titleSize = 20;
  double panelPadding = 20;

  double get notesHeight {
    if (widget.panelExpanded) {
      return widget.maxHeight - _footerSize - _titleSize - panelPadding;
    }
    return widget.minHeight - _titleSize - panelPadding;
  }

  @override
  Widget build(BuildContext context) {
    final TrackBloc trackBloc = Provider.of<TrackBloc>(context);
    final Color textColor =
        DefaultTextStyle.of(context).style.color ?? Colors.black;
    final Color mutedTextColor = textColor.withAlpha(155);

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

              return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Container(
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: MeasureSize(
                        onChange: (Size value) {
                          setState(() {
                            _titleSize = value.height;
                          });
                        },
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const BottomPanelHandle(),
                              Text.rich(
                                TextSpan(
                                    text: selectedSetlistTrack.plTrack!.title!,
                                    style: const TextStyle(fontSize: 16),
                                    children: <TextSpan>[
                                      if (selectedSetlistTrack
                                                  .plTrack!.artist !=
                                              null &&
                                          selectedSetlistTrack
                                              .plTrack!.artist!.isNotEmpty)
                                        TextSpan(
                                            text:
                                                ' - ${selectedSetlistTrack.plTrack!.artist}',
                                            style: TextStyle(
                                                color: mutedTextColor))
                                    ]),
                              )
                            ]))),
                if (!notesDocument.isEmpty())
                  Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 0.25,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      height: notesHeight,
                      margin: const EdgeInsets.all(8),
                      child: QuillEditor(
                        focusNode: _focusNode,
                        scrollController: _scrollController,
                        controller: notesController,
                        config: QuillEditorConfig(
                          showCursor: false,
                          maxHeight: notesHeight,
                          minHeight: notesHeight,
                          readOnlyMouseCursor: SystemMouseCursors.basic,
                          scrollable: true,
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 16,
                          ),
                          embedBuilders: <EmbedBuilder>[
                            ...FlutterQuillEmbeds.editorBuilders(
                              imageEmbedConfig: standardImageEmbedConfig,
                              videoEmbedConfig: standardVideoEmbedConfig,
                            ),
                          ],
                        ),
                      ))
                else
                  Container(
                    height: notesHeight,
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Add notes to track'),
                      onPressed: () {
                        trackBloc.selectItem(
                            selectedSetlistTrack, SelectionType.editing);
                      },
                    ),
                  ),
                if (widget.panelExpanded)
                  MeasureSize(
                      onChange: (Size value) => <void>{
                            setState(() {
                              _footerSize = value.height;
                            })
                          },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (selectedSetlistTrack
                                  .plTrack!.plTempos?.isNotEmpty ??
                              false)
                            StreamBuilder<ClickState>(
                                stream: trackBloc
                                    .indicatorStateBloc.clickStateStream,
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
                              label: const Text(
                                  'Add tempos to enable click track'),
                              onPressed: () {
                                trackBloc.selectItem(selectedSetlistTrack,
                                    SelectionType.editing);
                              },
                            )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              IconButton(
                                iconSize: 50,
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
                                  Widget toggleIcon;

                                  if (playbackStateSnapshot.data!.playing ||
                                      playbackStateSnapshot
                                              .data!.processingState ==
                                          AudioProcessingState.buffering) {
                                    toggleIcon = const Icon(Icons.pause);
                                  } else {
                                    toggleIcon = SvgPicture.asset(
                                      'assets/images/metronome-icon.svg',
                                      width: 65,
                                      height: 65,
                                      colorFilter: ColorFilter.mode(
                                          textColor, BlendMode.srcIn),
                                    );
                                  }

                                  bool disabled = false;
                                  if (selectedSetlistTrack.plTrack!.plTempos ==
                                          null ||
                                      selectedSetlistTrack
                                          .plTrack!.plTempos!.isEmpty) {
                                    disabled = true;
                                  }

                                  return IconButton(
                                      iconSize: 65,
                                      icon: toggleIcon,
                                      onPressed: disabled
                                          ? null
                                          : () {
                                              trackBloc.audioClick();
                                            });
                                },
                              ),
                              IconButton(
                                iconSize: 50,
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
                      ))
              ]);
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
