import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class MindMapPainter extends CustomPainter {
  final Map<String, TaskNode> nodeMap;
  final String? rootId;
  final Map<String, Rect> _nodeRects = {}; // Cache for hit testing

  // Layout constants
  final double nodeWidth = 120;
  final double nodeHeight = 50;
  final double hGap = 50;
  final double vGap = 20;

  MindMapPainter({
    required this.nodeMap,
    this.rootId,
  });

  Rect? getNodeRect(String id) => _nodeRects[id];
  String? hitTest(Offset position) {
    for (var entry in _nodeRects.entries) {
      if (entry.value.contains(position)) {
        return entry.key;
      }
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (rootId == null) return;
    _nodeRects.clear();

    _calculateLayout(rootId!, 0, size.height / 2);
    _drawTree(canvas, rootId!);
  }

  // Very naive recursive layout
  double _calculateLayout(String id, double x, double y) {
    // Center logic could be improved, but this works for PoC
    final node = nodeMap[id];
    if (node == null) return y;

    final children = nodeMap.values.where((n) => n.parentId == id).toList();

    // Store rect
    _nodeRects[id] = Rect.fromLTWH(x, y, nodeWidth, nodeHeight);

    if (children.isEmpty) {
      return y + nodeHeight + vGap;
    }

    double currentY = y - (children.length * (nodeHeight + vGap)) / 2;
    // ensure we don't overlap with parent's Y space too badly (naive)

    for (var child in children) {
      _calculateLayout(child.id, x + nodeWidth + hGap, currentY);
      currentY += nodeHeight + vGap;
    }
    return currentY;
  }

  void _drawTree(Canvas canvas, String id) {
    final rect = _nodeRects[id];
    if (rect == null) return;

    final paint = Paint()
      ..color = Colors.blue.shade100
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.blue.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final linePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    // Draw lines to children
    final children = nodeMap.values.where((n) => n.parentId == id).toList();
    for (var child in children) {
       final childRect = _nodeRects[child.id];
       if (childRect != null) {
         canvas.drawLine(
           rect.centerRight,
           childRect.centerLeft,
           linePaint
         );
         _drawTree(canvas, child.id);
       }
    }

    // Draw Node
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);

    // Draw Text
    final node = nodeMap[id]!;
    final textSpan = TextSpan(
      text: node.title,
      style: const TextStyle(color: Colors.black, fontSize: 12),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    );
    textPainter.layout(minWidth: 0, maxWidth: nodeWidth - 10);
    textPainter.paint(canvas, rect.topLeft + Offset(5, 5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MindMapView extends StatefulWidget {
  final List<TaskNode> nodes;
  final Function(TaskNode) onNodeTap;

  const MindMapView({super.key, required this.nodes, required this.onNodeTap});

  @override
  State<MindMapView> createState() => _MindMapViewState();
}

class _MindMapViewState extends State<MindMapView> {
  // We need to keep the painter to access hitTest
  MindMapPainter? _painter;

  @override
  Widget build(BuildContext context) {
    if (widget.nodes.isEmpty) return const Center(child: Text("No data"));

    // Find root
    final allIds = widget.nodes.map((n) => n.id).toSet();
    final root = widget.nodes.firstWhere(
      (n) => n.parentId == null || !allIds.contains(n.parentId),
      orElse: () => widget.nodes.first,
    );

    final map = {for (var n in widget.nodes) n.id: n};
    _painter = MindMapPainter(nodeMap: map, rootId: root.id);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapUp: (details) {
             final id = _painter?.hitTest(details.localPosition);
             if (id != null) {
               widget.onNodeTap(map[id]!);
             }
          },
          child: CustomPaint(
            size: Size(1500, 1000), // Fixed large canvas
            painter: _painter,
          ),
        );
      },
    );
  }
}
