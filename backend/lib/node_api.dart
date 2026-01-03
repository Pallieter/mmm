import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shared/shared.dart';
import 'node_repository.dart';

class NodeApi {
  final NodeRepository _repo;

  NodeApi(this._repo);

  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      final nodes = await _repo.getAllNodes();
      return Response.ok(
        jsonEncode(nodes.map((n) => n.toJson()).toList()),
        headers: {'content-type': 'application/json'},
      );
    });

    router.post('/', (Request request) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload);
      final node = TaskNode.fromJson(data);
      await _repo.createNode(node);
      return Response.ok(
        jsonEncode(node.toJson()),
        headers: {'content-type': 'application/json'},
      );
    });

    router.put('/<id>', (Request request, String id) async {
       final payload = await request.readAsString();
       final data = jsonDecode(payload);
       if (data['id'] != id) {
         return Response.badRequest(body: 'ID mismatch');
       }
       final node = TaskNode.fromJson(data);
       await _repo.updateNode(node);
       return Response.ok(
         jsonEncode(node.toJson()),
         headers: {'content-type': 'application/json'}
       );
    });

    router.delete('/<id>', (Request request, String id) async {
      await _repo.deleteNode(id);
      return Response.ok('Deleted');
    });

    return router;
  }
}
