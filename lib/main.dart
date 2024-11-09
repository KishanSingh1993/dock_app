import 'package:flutter/material.dart';

/// Entry point of the application.
void main() {
  runApp(const MyApp());
}

/// Main application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[icon.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(icon, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock with draggable and reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial items to put in the dock.
  final List<T> items;

  /// Builder function to render each item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T extends Object> extends State<Dock<T>> {
  /// Internal list of items to be manipulated.
  late List<T> _items = List.from(widget.items);

  /// Index of the currently dragged item.
  int? _draggingIndex;

  /// Temporarily stores the item being dragged.
  ///
  T? _draggedItem;

  /// Index of the target position where the dragged item will go.
  int? _targetIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          return _buildDraggableItem(item, index);
        }),
      ),
    );
  }

  Widget _buildDraggableItem(T item, int index) {
    final isBeingDragged = _draggingIndex == index;
    return Draggable<T>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: widget.builder(item),
      ),
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: () {
        setState(() {
          _draggingIndex = index;
          _draggedItem = item;
          _targetIndex = index;
        });
      },
      onDragEnd: (_) {
        setState(() {
          if (_targetIndex != null && _draggedItem != null) {
            // Rearranging the items based on target index after the drag ends
            _items.removeAt(_draggingIndex!);
            _items.insert(_targetIndex!, _draggedItem!);
          }
          _draggingIndex = null;
          _draggedItem = null;
          _targetIndex = null;
        });
      },
      child: DragTarget<T>(
        onWillAccept: (data) {
          if (data != null && _draggedItem != null) {
            setState(() {
              // As we hover the dragged item over a target position
              _targetIndex = index;
            });
          }
          return true;
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isBeingDragged
                ? const SizedBox.shrink() // Placeholder for the dragged item
                : widget.builder(item),
          );
        },
      ),
    );
  }
}