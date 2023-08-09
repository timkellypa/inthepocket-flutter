import 'dart:async';
import 'dart:collection';
import 'dart:io';

class TempServer {
  TempServer({this.port = '8080'});

  final String port;

  Uri get uri => Uri.parse('http://localhost:$port');

  static HashMap<String, HttpServer> portServerMap =
      HashMap<String, HttpServer>();

  Future<Stream<Map<String, String>>> queryParamListener() async {
    // stop any existing listeners on this port
    await stop(port);

    final StreamController<Map<String, String>> onparams =
        StreamController<Map<String, String>>();
    final HttpServer server =
        await HttpServer.bind(InternetAddress.anyIPv4, 8080);
    portServerMap.addEntries(<MapEntry<String, HttpServer>>[
      MapEntry<String, HttpServer>(port, server)
    ]);
    server.listen((HttpRequest request) async {
      final Map<String, String> queryParams = request.uri.queryParameters;
      request.response
        ..statusCode = 200
        ..headers.set('Content-Type', ContentType.html.mimeType)
        ..write('<html></html>');
      await request.response.close();
      await stop(port);
      if (!onparams.isClosed) {
        onparams.add(queryParams);
        await onparams.close();
      }
    });
    return onparams.stream;
  }

  /// stops server and removes from static map of servers (keyed by port)
  Future<void> stop(String port) async {
    if (portServerMap.containsKey(port)) {
      await portServerMap[port]!.close(force: true);
    }

    portServerMap.remove(port);
  }
}
