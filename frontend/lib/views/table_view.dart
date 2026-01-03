import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class TableView extends StatelessWidget {
  final List<TaskNode> nodes;

  const TableView({super.key, required this.nodes});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Title')),
            DataColumn(label: Text('Context')),
            DataColumn(label: Text('Priority')),
            DataColumn(label: Text('Owner')),
            DataColumn(label: Text('Access')),
          ],
          rows: nodes.map((node) {
            return DataRow(cells: [
              DataCell(Text(node.title)),
              DataCell(Text(node.context.toString().split('.').last)),
              DataCell(Text(node.priority.toString().split('.').last)),
              DataCell(Text(node.ownerId)),
              DataCell(Text(node.accessLevel.toString().split('.').last)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
