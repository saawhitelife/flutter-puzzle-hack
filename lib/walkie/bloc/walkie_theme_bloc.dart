import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:very_good_slide_puzzle/walkie/walkie.dart';

part 'walkie_theme_event.dart';
part 'walkie_theme_state.dart';

/// {@template walkie_theme_bloc}
/// Bloc responsible for the currently selected [WalkieTheme].
/// {@endtemplate}
class WalkieThemeBloc extends Bloc<WalkieThemeEvent, WalkieThemeState> {
  /// {@macro walkie_theme_bloc}
  WalkieThemeBloc({required List<WalkieTheme> themes})
      : super(WalkieThemeState(themes: themes)) {
    on<WalkieThemeChanged>(_onWalkieThemeChanged);
  }

  void _onWalkieThemeChanged(
    WalkieThemeChanged event,
    Emitter<WalkieThemeState> emit,
  ) {
    emit(state.copyWith(theme: state.themes[event.themeIndex]));
  }
}
