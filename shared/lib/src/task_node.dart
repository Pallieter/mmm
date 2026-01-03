import 'package:json_annotation/json_annotation.dart';
import 'enums.dart';

part 'task_node.g.dart';

@JsonSerializable()
class TaskNode {
  final String id;
  final String title;
  final String? description;
  final String? parentId;
  final List<String> childrenIds;

  final Context context;
  final Priority priority;
  final String ownerId;
  final AccessLevel accessLevel;
  final DateTime? specificDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  final int order;

  TaskNode({
    required this.id,
    required this.title,
    this.description,
    this.parentId,
    this.childrenIds = const [],
    required this.context,
    required this.priority,
    required this.ownerId,
    required this.accessLevel,
    this.specificDate,
    required this.createdAt,
    required this.updatedAt,
    this.order = 0,
  });

  factory TaskNode.fromJson(Map<String, dynamic> json) => _$TaskNodeFromJson(json);
  Map<String, dynamic> toJson() => _$TaskNodeToJson(this);

  TaskNode copyWith({
    String? id,
    String? title,
    String? description,
    String? parentId,
    List<String>? childrenIds,
    Context? context,
    Priority? priority,
    String? ownerId,
    AccessLevel? accessLevel,
    DateTime? specificDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? order,
  }) {
    return TaskNode(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? this.childrenIds,
      context: context ?? this.context,
      priority: priority ?? this.priority,
      ownerId: ownerId ?? this.ownerId,
      accessLevel: accessLevel ?? this.accessLevel,
      specificDate: specificDate ?? this.specificDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      order: order ?? this.order,
    );
  }
}
