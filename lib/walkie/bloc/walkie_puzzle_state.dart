// ignore_for_file: public_member_api_docs

part of 'walkie_puzzle_bloc.dart';

/// The status of [WalkiePuzzleState].
enum WalkiePuzzleStatus {
  /// The puzzle is not started yet.
  notStarted,

  /// The puzzle is loading.
  loading,

  /// The puzzle is started.
  started,

  /// Walkies are landing
  landing,
}

class WalkiePuzzleState extends Equatable {
  const WalkiePuzzleState({
    required this.secondsToBegin,
    this.isCountdownRunning = false,
    this.isLanding = false,
  });

  /// Whether the countdown of this puzzle is currently running.
  final bool isCountdownRunning;

  /// Whether walkies are landing
  final bool isLanding;

  /// The number of seconds before the puzzle is started.
  final int secondsToBegin;

  /// The status of the current puzzle.
  WalkiePuzzleStatus get status => isCountdownRunning && secondsToBegin > 0
      ? WalkiePuzzleStatus.loading
      : (secondsToBegin == 0
          ? WalkiePuzzleStatus.started
          : WalkiePuzzleStatus.notStarted);

  @override
  List<Object> get props => [isCountdownRunning, secondsToBegin];

  WalkiePuzzleState copyWith({
    bool? isCountdownRunning,
    int? secondsToBegin,
    bool? isLanding,
  }) {
    return WalkiePuzzleState(
      isCountdownRunning: isCountdownRunning ?? this.isCountdownRunning,
      secondsToBegin: secondsToBegin ?? this.secondsToBegin,
      isLanding: isLanding ?? this.isLanding,
    );
  }
}
