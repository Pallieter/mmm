// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskNode _$TaskNodeFromJson(Map<String, dynamic> json) => TaskNode(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  parentId: json['parentId'] as String?,
  childrenIds:
      (json['childrenIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  context: $enumDecode(_$ContextEnumMap, json['context']),
  priority: $enumDecode(_$PriorityEnumMap, json['priority']),
  ownerId: json['ownerId'] as String,
  accessLevel: $enumDecode(_$AccessLevelEnumMap, json['accessLevel']),
  specificDate: json['specificDate'] == null
      ? null
      : DateTime.parse(json['specificDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  order: (json['order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TaskNodeToJson(TaskNode instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'parentId': instance.parentId,
  'childrenIds': instance.childrenIds,
  'context': _$ContextEnumMap[instance.context]!,
  'priority': _$PriorityEnumMap[instance.priority]!,
  'ownerId': instance.ownerId,
  'accessLevel': _$AccessLevelEnumMap[instance.accessLevel]!,
  'specificDate': instance.specificDate?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'order': instance.order,
};

const _$ContextEnumMap = {
  Context.longFocusWorkInteractive: 'longFocusWorkInteractive',
  Context.longFocusWorkOffline: 'longFocusWorkOffline',
  Context.longFocusWorkOnline: 'longFocusWorkOnline',
  Context.shortTaskOffline: 'shortTaskOffline',
  Context.shortTaskOnline: 'shortTaskOnline',
  Context.shortTaskInteractive: 'shortTaskInteractive',
  Context.locationBased: 'locationBased',
};

const _$PriorityEnumMap = {
  Priority.now: 'now',
  Priority.today: 'today',
  Priority.soon: 'soon',
  Priority.later: 'later',
  Priority.specificDate: 'specificDate',
};

const _$AccessLevelEnumMap = {
  AccessLevel.private: 'private',
  AccessLevel.sharedWithWife: 'sharedWithWife',
  AccessLevel.sharedWithAssistants: 'sharedWithAssistants',
  AccessLevel.public: 'public',
};
