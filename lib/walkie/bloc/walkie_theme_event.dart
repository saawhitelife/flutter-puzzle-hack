// ignore_for_file: public_member_api_docs

part of 'walkie_theme_bloc.dart';

abstract class WalkieThemeEvent extends Equatable {
  const WalkieThemeEvent();
}

class WalkieThemeChanged extends WalkieThemeEvent {
  const WalkieThemeChanged({required this.themeIndex});

  /// The index of the changed theme in [WalkieThemeState.themes].
  final int themeIndex;

  @override
  List<Object> get props => [themeIndex];
}
