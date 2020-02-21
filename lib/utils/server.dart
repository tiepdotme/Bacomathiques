import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:mime/mime.dart';

/// Allows to create a local server.
/// Thanks to flutter_tex (https://github.com/shahxadakram/flutter_tex) for the base implementation of this class.
class Server {
  /// The http server.
  HttpServer _server;

  /// The port.
  final int port;

  /// All format arguments.
  Map<String, List<FormatArgument>> formatArguments;

  /// Creates a new server instance.
  Server([this.port = 8080, this.formatArguments]);

  /// Closes the server.
  Future<void> close() async {
    if (_server != null) {
      await _server.close(force: true);
      print('Server running on http://localhost:$port closed');
      _server = null;
    }
  }

  /// Starts the server.
  Future<void> start() async {
    if (_server != null) {
      throw Exception('Server already started on http://localhost:$port');
    }

    var completer = Completer();

    runZoned(() {
      HttpServer.bind('127.0.0.1', port).then((server) {
        print('Server running on http://localhost:' + port.toString());

        _server = server;

        server.listen((HttpRequest request) async {
          var path = request.requestedUri.path;
          path = (path.startsWith('/')) ? path.substring(1) : path;
          path += (path.endsWith('/')) ? 'index.html' : '';

          List<FormatArgument> arguments = formatArguments == null ? null : formatArguments[path];
          if (arguments == null) {
            await sendResponseWithoutFormatting(request, path);
            return;
          }

          await sendResponseWithFormatting(request, path, arguments);
        });

        completer.complete();
      });
    }, onError: (e, stackTrace) => print('Error: $e $stackTrace'));

    return completer.future;
  }

  /// Sends the response with formatting.
  Future<void> sendResponseWithFormatting(HttpRequest request, String path, List<FormatArgument> arguments) async {
    var body = '';

    try {
      body = await rootBundle.loadString(path);
    } catch (e) {
      print(e.toString());
      return request.response.close();
    }

    arguments.forEach((argument) {
      body = body.replaceAll('{' + argument.key + '}', argument.value);
    });

    var contentType = ['text', 'html'];
    if (!request.requestedUri.path.endsWith('/') && request.requestedUri.pathSegments.isNotEmpty) {
      var mimeType = lookupMimeType(request.requestedUri.path);
      if (mimeType != null) {
        contentType = mimeType.split('/');
      }
    }

    request.response.headers.contentType = ContentType(contentType[0], contentType[1], charset: 'utf-8');
    request.response.write(body);
    return request.response.close();
  }

  /// Sends the response without formatting.
  Future<void> sendResponseWithoutFormatting(HttpRequest request, String path) async {
    var body = [];

    try {
      body = (await rootBundle.load(path)).buffer.asUint8List();
    } catch (e) {
      print(e.toString());
      return request.response.close();
    }

    var contentType = ['text', 'html'];
    if (!request.requestedUri.path.endsWith('/') && request.requestedUri.pathSegments.isNotEmpty) {
      var mimeType = lookupMimeType(request.requestedUri.path, headerBytes: body);
      if (mimeType != null) {
        contentType = mimeType.split('/');
      }
    }

    request.response.headers.contentType = ContentType(contentType[0], contentType[1], charset: 'utf-8');
    request.response.add(body);
    return request.response.close();
  }
}

/// A format argument.
class FormatArgument {
  /// The key.
  String key;

  /// The value.
  String value;

  /// Creates a new format argument instance.
  FormatArgument(this.key, this.value);
}
