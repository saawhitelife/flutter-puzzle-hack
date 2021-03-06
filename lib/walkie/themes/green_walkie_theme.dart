import 'package:flutter/material.dart';
import 'package:very_good_slide_puzzle/colors/colors.dart';
import 'package:very_good_slide_puzzle/walkie/walkie.dart';
import 'package:very_good_slide_puzzle/l10n/l10n.dart';

/// {@template green_walkie_theme}
/// The green walkie puzzle theme.
/// {@endtemplate}
class GreenWalkieTheme extends WalkieTheme {
  /// {@macro green_walkie_theme}
  const GreenWalkieTheme() : super();

  @override
  String semanticsLabel(BuildContext context) =>
      context.l10n.walkieGreenDashLabelText;

  @override
  Color get backgroundColor => PuzzleColors.greenPrimary;

  @override
  Color get defaultColor => PuzzleColors.green90;

  @override
  Color get buttonColor => PuzzleColors.green50;

  @override
  Color get menuInactiveColor => PuzzleColors.green50;

  @override
  Color get countdownColor => PuzzleColors.green50;

  @override
  String get themeAsset => 'assets/images/dashatar/gallery/green.png';

  @override
  String get successThemeAsset => 'assets/images/dashatar/success/green.png';

  @override
  String get audioControlOffAsset =>
      'assets/images/audio_control/green_dashatar_off.png';

  @override
  String get audioAsset => 'assets/audio/skateboard.mp3';

  @override
  String get dashAssetsDirectory => 'assets/images/dashatar/green';
}
