import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:in_the_pocket/bloc/setlist_bloc.dart';
import 'package:in_the_pocket/bloc/spotify_playlist_bloc.dart';
import 'package:in_the_pocket/bloc/tempo_bloc.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/ui/pages/edit_tempo_form.dart';
import 'package:in_the_pocket/ui/pages/edit_track_form.dart';
import 'package:in_the_pocket/ui/navigation/edit_setlist_form_route_arguments.dart';
import 'package:in_the_pocket/ui/navigation/edit_tempo_form_route_arguments.dart';
import 'package:in_the_pocket/ui/navigation/edit_track_form_route_arguments.dart';
import 'package:in_the_pocket/ui/navigation/track_import_setlist_arguments.dart';
import 'package:in_the_pocket/ui/navigation/track_import_spotify_playlist_arguments.dart';
import 'package:in_the_pocket/ui/navigation/track_import_spotify_track_arguments.dart';
import 'package:in_the_pocket/ui/navigation/track_import_track_arguments.dart';
import 'package:in_the_pocket/ui/navigation/track_list_route_arguments.dart';
import 'package:in_the_pocket/ui/pages/setlist_list_page.dart';
import 'package:in_the_pocket/ui/pages/track_import_spotify_playlist_page.dart';
import 'package:in_the_pocket/ui/pages/track_import_spotify_track_page.dart';
import 'package:provider/provider.dart';

import '../pages/edit_setlist_form.dart';
import '../pages/track_import_setlist_page.dart';
import '../pages/track_import_track_page.dart';
import '../pages/track_list_page.dart';

// ignore: avoid_classes_with_only_static_members
class ApplicationRouter {
  static Map<String, WidgetBuilder> get routes {
    return <String, WidgetBuilder>{};
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    bool fullScreenDialog;
    Function builder;
    switch (settings.name) {
      case initialRoute:
        fullScreenDialog = false;
        builder = (BuildContext context) => const SetListListPage();
        break;
      case ROUTE_TRACK_LIST:
        fullScreenDialog = false;
        builder = (BuildContext context) {
          final TrackListRouteArguments args = settings.arguments;

          return Provider<SetListBloc>(
            builder: (BuildContext context) => args.setListBloc,
            dispose: (BuildContext context, SetListBloc value) =>
                value.unSelectItem(
              args.setList,
              SelectionType.selected,
            ),
            child: TrackListPage(setList: args.setList),
          );
        };
        break;
      case ROUTE_EDIT_SETLIST_FORM:
        fullScreenDialog = true;
        builder = (BuildContext context) {
          final EditSetListFormRouteArguments args = settings.arguments;

          return Provider<SetListBloc>(
              builder: (BuildContext context) => args.setListBloc,
              dispose: (BuildContext context, SetListBloc value) =>
                  value.unSelectItem(
                    args.setList,
                    SelectionType.add + SelectionType.editing,
                  ),
              child: EditSetListForm(setList: args.setList));
        };
        break;
      case ROUTE_TRACK_IMPORT_TRACK:
        fullScreenDialog = true;
        builder = (BuildContext context) {
          final TrackImportTrackArguments args = settings.arguments;
          return Provider<SetListBloc>(
            builder: (BuildContext context) => args.setListBloc,
            dispose: (BuildContext context, SetListBloc value) {
              value.unSelectItem(
                args.setList,
                SelectionType.selected,
              );
            },
            child: TrackImportTrackPage(
              args.targetSetList,
              setList: args.setList,
            ),
          );
        };
        break;
      case ROUTE_EDIT_TRACK_FORM:
        fullScreenDialog = true;
        builder = (BuildContext context) {
          final EditTrackFormRouteArguments args = settings.arguments;
          return Provider<TrackBloc>(
            builder: (BuildContext context) => args.trackBloc,
            dispose: (BuildContext context, TrackBloc value) =>
                value.unSelectItem(
              args.setListTrack,
              SelectionType.editing +
                  SelectionType.add +
                  SelectionType.selected,
            ),
            child: EditTrackForm(
              args.setList,
              setListTrack: args.setListTrack,
            ),
          );
        };
        break;
      case ROUTE_TRACK_IMPORT_SETLIST:
        fullScreenDialog = true;
        builder = (BuildContext context) {
          final TrackImportSetListArguments args = settings.arguments;
          return Provider<TrackBloc>(
            builder: (BuildContext context) => args.trackBloc,
            dispose: (BuildContext context, TrackBloc value) => value.fetch(),
            child: TrackImportSetlistPage(args.setList),
          );
        };
        break;
      case ROUTE_TRACK_IMPORT_SPOTIFY_PLAYLIST:
        fullScreenDialog = true;
        builder = (BuildContext context) {
          final TrackImportSpotifyPlaylistArguments args = settings.arguments;
          return Provider<TrackBloc>(
            builder: (BuildContext context) => args.trackBloc,
            dispose: (BuildContext context, TrackBloc value) => value.fetch(),
            child: TrackImportSpotifyPlaylistPage(args.setList),
          );
        };
        break;
      case ROUTE_TRACK_IMPORT_SPOTIFY_TRACK:
        fullScreenDialog = true;
        builder = (BuildContext context) {
          final TrackImportSpotifyTrackArguments args = settings.arguments;
          return Provider<SpotifyPlaylistBloc>(
            builder: (BuildContext context) => args.spotifyPlaylistBloc,
            dispose: (BuildContext context, SpotifyPlaylistBloc value) =>
                value.unSelectItem(
              args.spotifyPlaylist,
              SelectionType.editing +
                  SelectionType.add +
                  SelectionType.selected,
            ),
            child: TrackImportSpotifyTrackPage(
              args.targetSetList,
              spotifyPlaylist: args.spotifyPlaylist,
            ),
          );
        };
        break;
      case ROUTE_EDIT_TEMPO_FORM:
        fullScreenDialog = true;
        builder = (BuildContext context) {
          final EditTempoFormRouteArguments args = settings.arguments;
          return Provider<TempoBloc>(
            builder: (BuildContext context) => args.tempoBloc,
            dispose: (BuildContext context, TempoBloc value) =>
                value.unSelectItem(
              args.tempo,
              SelectionType.editing +
                  SelectionType.add +
                  SelectionType.selected,
            ),
            child: EditTempoForm(
              tempo: args.tempo,
            ),
          );
        };
        break;
    }

    if (builder != null) {
      return MaterialPageRoute<dynamic>(
        fullscreenDialog: fullScreenDialog,
        settings: RouteSettings(name: settings.name),
        builder: builder,
      );
    }
    return null;
  }

  static const String initialRoute = '/';

  static const String ROUTE_TRACK_LIST = '/track_list';
  static const String ROUTE_EDIT_SETLIST_FORM = '/edit_setlist_form';
  static const String ROUTE_TRACK_IMPORT_TRACK = '/track_import_track';
  static const String ROUTE_EDIT_TRACK_FORM = '/edit_track_form';
  static const String ROUTE_TRACK_IMPORT_SETLIST = '/track_import_setlist';
  static const String ROUTE_TRACK_IMPORT_SPOTIFY_PLAYLIST =
      '/track_import_spotify_playlist';
  static const String ROUTE_TRACK_IMPORT_SPOTIFY_TRACK =
      '/track_import_spotify_track';
  static const String ROUTE_EDIT_TEMPO_FORM = '/edit_tempo_form';
}
