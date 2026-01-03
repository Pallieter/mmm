import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';
import 'auth_provider.dart';
import 'node_provider.dart';
import 'views/mind_map_view.dart';
import 'views/table_view.dart';
import 'views/tree_view_widget.dart';
import 'views/node_editor.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

enum ViewType { mindMap, tree, table }

class _DashboardScreenState extends State<DashboardScreen> {
  ViewType _currentView = ViewType.mindMap;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<NodeProvider>().fetchNodes();
    });
  }

  void _showEditor(BuildContext context, {TaskNode? node}) async {
      final auth = context.read<AuthProvider>();
      final user = auth.appUser;
      if (user == null) return;

      final result = await showDialog<TaskNode>(
        context: context,
        builder: (context) => NodeEditorDialog(
          node: node,
          ownerId: user.id,
          parentId: node?.parentId,
        ),
      );

      if (result != null && mounted) {
        final provider = context.read<NodeProvider>();
        if (node == null) {
          // Creating new Root
           final newNode = result.copyWith(id: const Uuid().v4());
           provider.addNode(newNode);
        } else if (result.id.isEmpty) {
           // Creating child (logic from editor)
           final newNode = result.copyWith(id: const Uuid().v4());
           provider.addNode(newNode);
        } else {
           // Updating
           provider.updateNode(result);
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final nodeProvider = context.watch<NodeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MMM Dashboard'),
        actions: [
          DropdownButton<ViewType>(
            value: _currentView,
            icon: const Icon(Icons.view_list, color: Colors.white),
            dropdownColor: Colors.blue,
            underline: Container(),
            onChanged: (ViewType? newValue) {
              if (newValue != null) {
                setState(() => _currentView = newValue);
              }
            },
            items: const [
               DropdownMenuItem(value: ViewType.mindMap, child: Text('Mind Map', style: TextStyle(color: Colors.black))),
               DropdownMenuItem(value: ViewType.tree, child: Text('Tree', style: TextStyle(color: Colors.black))),
               DropdownMenuItem(value: ViewType.table, child: Text('Table', style: TextStyle(color: Colors.black))),
            ],
          ),
          const SizedBox(width: 20),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.signOut(),
          ),
        ],
      ),
      body: nodeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(nodeProvider.nodes),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(context), // Add Root Node
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(List<TaskNode> nodes) {
    switch (_currentView) {
      case ViewType.mindMap:
        return MindMapView(
          nodes: nodes,
          onNodeTap: (node) => _showEditor(context, node: node),
        );
      case ViewType.tree:
        return TreeViewWidget(
          nodes: nodes,
          onNodeTap: (node) => _showEditor(context, node: node),
        );
      case ViewType.table:
        return TableView(nodes: nodes);
    }
  }
}
