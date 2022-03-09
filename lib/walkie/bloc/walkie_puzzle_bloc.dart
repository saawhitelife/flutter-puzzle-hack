import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:very_good_slide_puzzle/models/models.dart';

part 'walkie_puzzle_event.dart';
part 'walkie_puzzle_state.dart';

/// {@template walkie_puzzle_bloc}
/// A bloc responsible for starting the Walkie puzzle.
/// {@endtemplate}
class WalkiePuzzleBloc extends Bloc<WalkiePuzzleEvent, WalkiePuzzleState> {
  /// {@macro walkie_puzzle_bloc}
  WalkiePuzzleBloc({
    required this.secondsToBegin,
    required Ticker ticker,
  })  : _ticker = ticker,
        super(WalkiePuzzleState(secondsToBegin: secondsToBegin)) {
    on<WalkieCountdownStarted>(_onCountdownStarted);
    on<WalkieCountdownTicked>(_onCountdownTicked);
    on<WalkieCountdownStopped>(_onCountdownStopped);
    on<WalkieCountdownReset>(_onCountdownReset);
    on<WalkieLandingStart>(_onWalkieLandingStart);
  }

  /// The number of seconds before the puzzle is started.
  final int secondsToBegin;

  final Ticker _ticker;

  StreamSubscription<int>? _tickerSubscription;

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _startTicker() {
    _tickerSubscription?.cancel();
    _tickerSubscription =
        _ticker.tick().listen((_) => add(const WalkieCountdownTicked()));
  }

  void _onWalkieLandingStart(
    WalkieLandingStart event,
    Emitter<WalkiePuzzleState> emit,
  ) {
    emit(
      state.copyWith(isLanding: true),
    );
  }

  void _onCountdownStarted(
    WalkieCountdownStarted event,
    Emitter<WalkiePuzzleState> emit,
  ) {
    _startTicker();
    emit(
      state.copyWith(
        isCountdownRunning: true,
        secondsToBegin: secondsToBegin,
      ),
    );
  }

  void _onCountdownTicked(
    WalkieCountdownTicked event,
    Emitter<WalkiePuzzleState> emit,
  ) {
    if (state.secondsToBegin == 0) {
      _tickerSubscription?.pause();
      emit(state.copyWith(isCountdownRunning: false));
    } else {
      emit(state.copyWith(secondsToBegin: state.secondsToBegin - 1));
    }
  }

  void _onCountdownStopped(
    WalkieCountdownStopped event,
    Emitter<WalkiePuzzleState> emit,
  ) {
    _tickerSubscription?.pause();
    emit(
      state.copyWith(
        isCountdownRunning: false,
        secondsToBegin: secondsToBegin,
      ),
    );
  }

  void _onCountdownReset(
    WalkieCountdownReset event,
    Emitter<WalkiePuzzleState> emit,
  ) {
    _startTicker();
    emit(
      state.copyWith(
        isCountdownRunning: true,
        secondsToBegin: event.secondsToBegin,
      ),
    );
  }
}
