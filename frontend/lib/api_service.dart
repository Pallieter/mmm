import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';

class ApiService {
  final String baseUrl;
  String? _authToken;

  ApiService({required this.baseUrl});

  void setToken(String token) {
    _authToken = token;
  }

  Future<List<TaskNode>> getNodes() async {
    final response = await http.get(Uri.parse('$baseUrl/api/nodes/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TaskNode.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load nodes');
    }
  }

  Future<TaskNode> createNode(TaskNode node) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/nodes/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(node.toJson()),
    );
    if (response.statusCode == 200) {
      return TaskNode.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create node');
    }
  }

  Future<void> updateNode(TaskNode node) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/nodes/${node.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(node.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update node');
    }
  }

  Future<void> deleteNode(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/nodes/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete node');
    }
  }
}
