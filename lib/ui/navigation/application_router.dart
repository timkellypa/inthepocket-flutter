import 'package:flutter/material.dart';
import 'package:in_the_pocket/bloc/setlist_bloc.dart';
import 'package:in_the_pocket/bloc/spotify_playlist_bloc.dart';
import 'package:in_the_pocket/bloc/tempo_bloc.dart';
import 'package:in_the_pocket/bloc/track_bloc.dart';
import 'package:in_the_pocket/classes/selection_type.dart';
import 'package:in_the_pocket/ui/navigation/edit_setlist_form_route_arguments.dart';
import 'package:in_the_pocket/ui/navigation/edit_tempo_form_route_arguments.dart';
import 'package:in_the_pocket/ui/navigation/edit_track_form_route_arguments.dart';
import 'package:in_the_pocket/ui/navigation/track_import_setlist_arguments.dart';
import 'package:in_the_pocket/ui/navigation/track_import_spotify_playlist_arguments.dart';
import 'package:in_the_pocket/ui/navigation/track_import_spotify_track_arguments.dart';
import 'package:in_the_pocket/ui/navigation/track_import_track_arguments.dart';
import 'package:in_the_pocket/ui/navigation/track_list_route_arguments.dart';
import 'package:in_the_pocket/ui/pages/edit_tempo_form.dart';
import 'package:in_the_pocket/ui/pages/edit_track_form.dart';
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
    // initial route, default values.
    bool fullScreenDialog = false;
    Widget Function(BuildContext) builder =
        (BuildContext context) => const SetlistListPage();
    switch (settings.name) {
      case initialRoute:
        break;
      case ROUTE_TRACK_LIST:
        fullScreenDialog = false;
        builder = (BuildContext context) {
          final TrackListRouteArguments args =
              settings.arguments as TrackListRouteArguments;

          args.setlistBloc.reset();

          return Provider<SetlistBloc>(
            create: (BuildContext context) => args.setlistBloc,
            child: TrackListPage(setlist: args.setlist),
          );
        };
        break;
      case ROUTE_EDIT_SETLIST_FORM:
        fullScreenDialog = true;
        builder = (BuildContext context) {
          final EditSetlistFormRouteArguments args =
              settings.arguments as EditSetlistFormRouteArguments;

          args.setlistBloc.reset();

          return Provider<SetlistBloc>(
              create: (BuildContext context) => args.setlistBloc,
              child: EditSetlistForm(setlist: args.setlist));
        };
        break;
      case ROUTE_TRACK_IMPORT_TRACK:
        fullScreenDialog = true;
        builder = (BuildContext context) {
          final TrackImportTrackArguments args =
              settings.arguments as TrackImportTrackArguments;

          args.setlistBloc.reset();

          return Provider<SetlistBloc>(
            create: (BuildContext context) => args.setlistBloc,
            dispose: (BuildContext context, SetlistBloc value) {
              value.unSelectItem(
                args.setlist!,
                SelectionType.selected,
              );
            },
            child: TrackImportTrackPage(
              args.targetSetlist,
              setlist: args.setlist,
            ),
          );
        };
        break;
      case ROUTE_EDIT_TRACK_FORM:
        fullScreenDialog = true;
        builder = (BuildContext context) {
          final EditTrackFormRouteArguments args =
              settings.arguments as EditTrackFormRouteArguments;

          args.trackBloc.reset();

          return Provider<TrackBloc>(
            create: (BuildContext context) => args.trackBloc,
            child: EditTrackForm(
              args.setlist!,
              setlistTrack: args.setlistTrack,
            ),
          );
        };
        break;
      case ROUTE_TRACK_IMPORT_SETLIST:
        fullScreenDialog = true;
        builder = (BuildContext context) {
          final TrackImportSetlistArguments args =
              settings.arguments as TrackImportSetlistArguments;
          return Provider<TrackBloc>(
            create: (BuildContext context) => args.trackBloc,
            dispose: (BuildContext context, TrackBloc value) => value.fetch(),
            child: TrackImportSetlistPage(args.setlist!),
          );
        };
        break;
      case ROUTE_TRACK_IMPORT_SPOTIFY_PLAYLIST:
        fullScreenDialog = true;
        builder = (BuildContext context) {
          final TrackImportSpotifyPlaylistArguments args =
              settings.arguments as TrackImportSpotifyPlaylistArguments;
          return Provider<TrackBloc>(
            create: (BuildContext context) => args.trackBloc,
            dispose: (BuildContext context, TrackBloc value) => value.fetch(),
            child: TrackImportSpotifyPlaylistPage(args.setlist),
          );
        };
        break;
      case ROUTE_TRACK_IMPORT_SPOTIFY_TRACK:
        fullScreenDialog = true;
        builder = (BuildContext context) {
          final TrackImportSpotifyTrackArguments args =
              settings.arguments as TrackImportSpotifyTrackArguments;

          // Fetching concurrently from spotify API causes big OAuth issues.
          // Syncing selections should be enough here.
          args.spotifyPlaylistBloc.reset();

          return Provider<SpotifyPlaylistBloc>(
            create: (BuildContext context) => args.spotifyPlaylistBloc,
            dispose: (BuildContext context, SpotifyPlaylistBloc value) =>
                value.unSelectItem(
              args.spotifyPlaylist,
              SelectionType.editing +
                  SelectionType.add +
                  SelectionType.selected,
            ),
            child: TrackImportSpotifyTrackPage(
              args.targetSetlist,
              spotifyPlaylist: args.spotifyPlaylist,
            ),
          );
        };
        break;
      case ROUTE_EDIT_TEMPO_FORM:
        fullScreenDialog = true;
        builder = (BuildContext context) {
          final EditTempoFormRouteArguments args =
              settings.arguments as EditTempoFormRouteArguments;
          return Provider<TempoBloc>(
            create: (BuildContext context) => args.tempoBloc,
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

    return MaterialPageRoute<dynamic>(
      fullscreenDialog: fullScreenDialog,
      settings: RouteSettings(name: settings.name),
      builder: builder,
    );
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
