import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class NodeEditorDialog extends StatefulWidget {
  final TaskNode? node;
  final String? parentId;
  final String ownerId;

  const NodeEditorDialog({super.key, this.node, this.parentId, required this.ownerId});

  @override
  State<NodeEditorDialog> createState() => _NodeEditorDialogState();
}

class _NodeEditorDialogState extends State<NodeEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late Context _context;
  late Priority _priority;
  late AccessLevel _accessLevel;

  // If true, we are creating a child of the current node instead of editing it
  bool _isAddingChild = false;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  void _initFields() {
    if (_isAddingChild) {
      _titleController = TextEditingController(text: '');
      _descController = TextEditingController(text: '');
      _context = Context.shortTaskOffline;
      _priority = Priority.now;
      _accessLevel = AccessLevel.private;
    } else {
      _titleController = TextEditingController(text: widget.node?.title ?? '');
      _descController = TextEditingController(text: widget.node?.description ?? '');
      _context = widget.node?.context ?? Context.shortTaskOffline;
      _priority = widget.node?.priority ?? Priority.now;
      _accessLevel = widget.node?.accessLevel ?? AccessLevel.private;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isAddingChild
       ? 'Add Child to "${widget.node?.title}"'
       : (widget.node == null ? 'Add Root Task' : 'Edit Task');

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isAddingChild && widget.node != null) ...[
                 OutlinedButton.icon(
                   onPressed: () {
                     setState(() {
                       _isAddingChild = true;
                       _initFields();
                     });
                   },
                   icon: const Icon(Icons.add_link),
                   label: const Text('Add Child Node'),
                 ),
                 const Divider(),
              ],
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              DropdownButtonFormField<Context>(
                value: _context,
                decoration: const InputDecoration(labelText: 'Context'),
                items: Context.values.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c.toString().split('.').last));
                }).toList(),
                onChanged: (v) => setState(() => _context = v!),
              ),
              DropdownButtonFormField<Priority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: Priority.values.map((p) {
                  return DropdownMenuItem(value: p, child: Text(p.toString().split('.').last));
                }).toList(),
                onChanged: (v) => setState(() => _priority = v!),
              ),
              DropdownButtonFormField<AccessLevel>(
                value: _accessLevel,
                decoration: const InputDecoration(labelText: 'Access Level'),
                items: AccessLevel.values.map((a) {
                  return DropdownMenuItem(value: a, child: Text(a.toString().split('.').last));
                }).toList(),
                onChanged: (v) => setState(() => _accessLevel = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (_isAddingChild)
           TextButton(
             onPressed: () {
               setState(() {
                 _isAddingChild = false;
                 _initFields();
               });
             },
             child: const Text('Back to Edit')
           ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
               TaskNode resultNode;

               if (_isAddingChild) {
                  // Creating a new child
                  resultNode = TaskNode(
                    id: '', // Empty ID signals creation
                    title: _titleController.text,
                    description: _descController.text,
                    parentId: widget.node!.id, // Parent is the node we were editing
                    context: _context,
                    priority: _priority,
                    ownerId: widget.ownerId,
                    accessLevel: _accessLevel,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
               } else {
                  // Editing existing or creating root
                  resultNode = widget.node?.copyWith(
                      title: _titleController.text,
                      description: _descController.text,
                      context: _context,
                      priority: _priority,
                      accessLevel: _accessLevel,
                      updatedAt: DateTime.now(),
                   ) ?? TaskNode(
                      id: '',
                      title: _titleController.text,
                      description: _descController.text,
                      parentId: widget.parentId,
                      context: _context,
                      priority: _priority,
                      ownerId: widget.ownerId,
                      accessLevel: _accessLevel,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                   );
               }
               Navigator.pop(context, resultNode);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
