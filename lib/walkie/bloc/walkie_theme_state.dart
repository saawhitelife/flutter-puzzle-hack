// ignore_for_file: public_member_api_docs

part of 'walkie_theme_bloc.dart';

class WalkieThemeState extends Equatable {
  const WalkieThemeState({
    required this.themes,
    this.theme = const BlueWalkieTheme(),
  });

  /// The list of all available [WalkieTheme]s.
  final List<WalkieTheme> themes;

  /// Currently selected [WalkieTheme].
  final WalkieTheme theme;

  @override
  List<Object> get props => [themes, theme];

  WalkieThemeState copyWith({
    List<WalkieTheme>? themes,
    WalkieTheme? theme,
  }) {
    return WalkieThemeState(
      themes: themes ?? this.themes,
      theme: theme ?? this.theme,
    );
  }
}
