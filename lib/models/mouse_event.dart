/// Mouse event type
enum MouseEventType {
  /// Mouse hovers
  hover,

  /// Mouse enters
  enter,

  /// Mouse exits
  exit
}

/// Represents a mouse event in the root MouseRegionWidget
class MouseEvent {
  ///
  const MouseEvent({
    required this.x,
    required this.y,
    required this.type,
  });

  /// x mouse position on event
  final double x;

  /// y mouse position on event
  final double y;

  /// Event type
  final MouseEventType type;

  /// Floor of x
  int get xFloor => x.floor();

  /// Floor of y
  int get yFloor => y.floor();
}
