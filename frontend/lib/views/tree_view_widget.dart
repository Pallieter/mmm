import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class TreeViewWidget extends StatelessWidget {
  final List<TaskNode> nodes;
  final Function(TaskNode) onNodeTap;

  const TreeViewWidget({super.key, required this.nodes, required this.onNodeTap});

  List<Widget> _buildTree(String? parentId) {
    final children = nodes.where((n) => n.parentId == parentId).toList();

    return children.map((node) {
      final grandChildren = _buildTree(node.id);

      if (grandChildren.isEmpty) {
        return ListTile(
          title: Text(node.title),
          subtitle: Text('${node.priority.name} - ${node.context.name}'),
          leading: const Icon(Icons.circle, size: 8),
          onTap: () => onNodeTap(node),
        );
      } else {
        return ExpansionTile(
          title: Text(node.title),
          subtitle: Text('${node.priority.name} - ${node.context.name}'),
          children: grandChildren,
        );
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (nodes.isEmpty) return const Center(child: Text("No data"));

    final allIds = nodes.map((n) => n.id).toSet();
    final roots = nodes.where((n) => n.parentId == null || !allIds.contains(n.parentId)).toList();

    return ListView(
      children: roots.map((root) {
        final children = _buildTree(root.id);
        if (children.isEmpty) {
             return ListTile(
               title: Text(root.title),
               leading: const Icon(Icons.folder),
               onTap: () => onNodeTap(root),
             );
        }
        return ExpansionTile(
          title: Text(root.title),
          leading: const Icon(Icons.folder),
          children: children,
        );
      }).toList(),
    );
  }
}
