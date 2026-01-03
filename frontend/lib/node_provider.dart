import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';
import 'api_service.dart';

class NodeProvider extends ChangeNotifier {
  final ApiService _api;
  List<TaskNode> _nodes = [];
  bool _isLoading = false;

  List<TaskNode> get nodes => _nodes;
  bool get isLoading => _isLoading;

  NodeProvider(this._api);

  Future<void> fetchNodes() async {
    _isLoading = true;
    notifyListeners();
    try {
      _nodes = await _api.getNodes();
    } catch (e) {
      print('Error fetching nodes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNode(TaskNode node) async {
    try {
      final newNode = await _api.createNode(node);
      _nodes.add(newNode);
      notifyListeners();
    } catch (e) {
      print('Error adding node: $e');
    }
  }

  Future<void> updateNode(TaskNode node) async {
    try {
      await _api.updateNode(node);
      final index = _nodes.indexWhere((n) => n.id == node.id);
      if (index != -1) {
        _nodes[index] = node;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating node: $e');
    }
  }

  Future<void> deleteNode(String id) async {
    try {
      await _api.deleteNode(id);
      _nodes.removeWhere((n) => n.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting node: $e');
    }
  }

  TaskNode createNewNodeTemplate({required String parentId, required String ownerId}) {
    return TaskNode(
      id: const Uuid().v4(),
      title: 'New Task',
      parentId: parentId.isEmpty ? null : parentId,
      context: Context.shortTaskOffline,
      priority: Priority.now,
      ownerId: ownerId,
      accessLevel: AccessLevel.private,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
