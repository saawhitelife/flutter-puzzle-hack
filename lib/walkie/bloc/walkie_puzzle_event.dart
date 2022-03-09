// ignore_for_file: public_member_api_docs

part of 'walkie_puzzle_bloc.dart';

abstract class WalkiePuzzleEvent extends Equatable {
  const WalkiePuzzleEvent();

  @override
  List<Object?> get props => [];
}

class WalkieCountdownStarted extends WalkiePuzzleEvent {
  const WalkieCountdownStarted();
}

class WalkieCountdownTicked extends WalkiePuzzleEvent {
  const WalkieCountdownTicked();
}

class WalkieCountdownStopped extends WalkiePuzzleEvent {
  const WalkieCountdownStopped();
}

class WalkieCountdownReset extends WalkiePuzzleEvent {
  const WalkieCountdownReset({this.secondsToBegin = 3});

  /// The number of seconds to countdown from.
  /// Defaults to [WalkiePuzzleBloc.secondsToBegin] if null.
  final int secondsToBegin;

  @override
  List<Object?> get props => [secondsToBegin];
}

class WalkieLandingStart extends WalkiePuzzleEvent {
  const WalkieLandingStart();
}
