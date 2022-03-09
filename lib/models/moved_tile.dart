import 'package:very_good_slide_puzzle/models/models.dart';

/// This class holds a tile that has been moved after a tile tap and the move di
/// rection
class MovedTile {
  ///
  const MovedTile({
    required this.tile,
    required this.moveDirection,
  });

  /// A tile that has been moved
  final Tile tile;

  /// The direction in which the tile has been moved
  final MoveDirection moveDirection;
}
