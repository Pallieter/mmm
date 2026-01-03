import 'dart:convert';
import 'package:shared/shared.dart';
import 'database_service.dart';

class NodeRepository {
  final DatabaseService _db;

  NodeRepository(this._db);

  Future<List<TaskNode>> getAllNodes() async {
    final result = await _db.execute('SELECT * FROM task_nodes');
    final nodes = <TaskNode>[];

    for (final row in result.rows) {
      nodes.add(_mapRowToNode(row));
    }
    return nodes;
  }

  Future<TaskNode?> getNodeById(String id) async {
    final result = await _db.execute('SELECT * FROM task_nodes WHERE id = :id', {'id': id});
    if (result.rows.isEmpty) return null;
    return _mapRowToNode(result.rows.first);
  }

  Future<void> createNode(TaskNode node) async {
    await _db.execute('''
      INSERT INTO task_nodes (
        id, title, description, parent_id, children_ids, context, priority,
        owner_id, access_level, specific_date, created_at, updated_at, sort_order
      ) VALUES (
        :id, :title, :description, :parent_id, :children_ids, :context, :priority,
        :owner_id, :access_level, :specific_date, :created_at, :updated_at, :sort_order
      )
    ''', {
      'id': node.id,
      'title': node.title,
      'description': node.description,
      'parent_id': node.parentId,
      'children_ids': jsonEncode(node.childrenIds),
      'context': node.context.toString(),
      'priority': node.priority.toString(),
      'owner_id': node.ownerId,
      'access_level': node.accessLevel.toString(),
      'specific_date': node.specificDate?.toIso8601String(),
      'created_at': node.createdAt.toIso8601String(),
      'updated_at': node.updatedAt.toIso8601String(),
      'sort_order': node.order,
    });
  }

  Future<void> updateNode(TaskNode node) async {
      await _db.execute('''
      UPDATE task_nodes SET
        title = :title,
        description = :description,
        parent_id = :parent_id,
        children_ids = :children_ids,
        context = :context,
        priority = :priority,
        owner_id = :owner_id,
        access_level = :access_level,
        specific_date = :specific_date,
        updated_at = :updated_at,
        sort_order = :sort_order
      WHERE id = :id
    ''', {
      'id': node.id,
      'title': node.title,
      'description': node.description,
      'parent_id': node.parentId,
      'children_ids': jsonEncode(node.childrenIds),
      'context': node.context.toString(),
      'priority': node.priority.toString(),
      'owner_id': node.ownerId,
      'access_level': node.accessLevel.toString(),
      'specific_date': node.specificDate?.toIso8601String(),
      'updated_at': node.updatedAt.toIso8601String(),
      'sort_order': node.order,
    });
  }

  Future<void> deleteNode(String id) async {
     await _db.execute('DELETE FROM task_nodes WHERE id = :id', {'id': id});
  }

  TaskNode _mapRowToNode(dynamic row) {
    T parseEnum<T>(List<T> values, String str) {
      return values.firstWhere(
        (e) => e.toString() == str,
        orElse: () => values.first,
      );
    }

    return TaskNode(
      id: row.colByName('id') as String,
      title: row.colByName('title') as String,
      description: row.colByName('description') as String?,
      parentId: row.colByName('parent_id') as String?,
      childrenIds: (jsonDecode(row.colByName('children_ids') as String? ?? '[]') as List).cast<String>(),
      context: parseEnum(Context.values, row.colByName('context') as String),
      priority: parseEnum(Priority.values, row.colByName('priority') as String),
      ownerId: row.colByName('owner_id') as String,
      accessLevel: parseEnum(AccessLevel.values, row.colByName('access_level') as String),
      specificDate: row.colByName('specific_date') != null
          ? DateTime.parse(row.colByName('specific_date') as String)
          : null,
      createdAt: DateTime.parse(row.colByName('created_at') as String),
      updatedAt: DateTime.parse(row.colByName('updated_at') as String),
      order: int.tryParse(row.colByName('sort_order').toString()) ?? 0,
    );
  }
}
