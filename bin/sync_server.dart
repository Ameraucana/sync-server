import 'dart:io';

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:path/path.dart' as path;

void main() async {
  var router = Router();

  router.post('/up/<sender>', (Request request, String sender) async {
    await writeSave(sender, request);
    return Response.ok('save was pushed');
  });

  router.get('/down/<sender>', (Request request, String sender) async {
    var saveFile = await readSave(sender);
    return Response.ok(saveFile);
  });

  var server = await io.serve(router, InternetAddress.anyIPv4, 8080);
  print('now serving on port ${server.port} (see ipconfig for host address)');
}

Future<void> writeSave(String target, Request request) async {
  var savePath = path.join('saves', '$target.json');
  var pathExists = await Directory('saves').exists();
  if (!pathExists) {
    await Directory('saves').create(recursive: true);
  }
  var saveFile = File(savePath);
  var downstreamSaveContent = await request.readAsString();
  await saveFile.writeAsString(downstreamSaveContent);
}

Future<String> readSave(String target) async {
  var savePath = path.join('saves', '$target.json');
  var saveFile = File(savePath);
  var downstreamSaveContent = await saveFile.readAsString();
  return downstreamSaveContent;
}
