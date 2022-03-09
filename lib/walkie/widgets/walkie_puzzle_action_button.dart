import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:very_good_slide_puzzle/audio_control/audio_control.dart';
import 'package:very_good_slide_puzzle/walkie/walkie.dart';
import 'package:very_good_slide_puzzle/helpers/helpers.dart';
import 'package:very_good_slide_puzzle/l10n/l10n.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/theme/theme.dart';
import 'package:very_good_slide_puzzle/timer/timer.dart';

/// {@template walkie_puzzle_action_button}
/// Displays the action button to start or shuffle the puzzle
/// based on the current puzzle state.
/// {@endtemplate}
class WalkiePuzzleActionButton extends StatefulWidget {
  /// {@macro walkie_puzzle_action_button}
  const WalkiePuzzleActionButton({Key? key, AudioPlayerFactory? audioPlayer})
      : _audioPlayerFactory = audioPlayer ?? getAudioPlayer,
        super(key: key);

  final AudioPlayerFactory _audioPlayerFactory;

  @override
  State<WalkiePuzzleActionButton> createState() =>
      _WalkiePuzzleActionButtonState();
}

class _WalkiePuzzleActionButtonState extends State<WalkiePuzzleActionButton> {
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = widget._audioPlayerFactory()
      ..setAsset('assets/audio/click.mp3');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.select((WalkieThemeBloc bloc) => bloc.state.theme);

    final status = context.select((WalkiePuzzleBloc bloc) => bloc.state.status);
    final isLoading = status == WalkiePuzzleStatus.loading;
    final isStarted = status == WalkiePuzzleStatus.started;

    final text = isStarted
        ? context.l10n.walkieRestart
        : (isLoading
            ? context.l10n.walkieGetReady
            : context.l10n.walkieStartGame);

    return AudioControlListener(
      audioPlayer: _audioPlayer,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Tooltip(
          key: ValueKey(status),
          message: isStarted ? context.l10n.puzzleRestartTooltip : '',
          verticalOffset: 40,
          child: PuzzleButton(
            onPressed: isLoading
                ? null
                : () async {
                    // final hasStarted = status == WalkiePuzzleStatus.started;

                    // Reset the timer and the countdown.
                    context.read<TimerBloc>().add(const TimerReset());
                    context.read<WalkiePuzzleBloc>().add(
                          const WalkieCountdownReset(),
                        );

                    // Initialize the puzzle board to show the initial puzzle
                    // (unshuffled) before the countdown completes.
                    // if (hasStarted) {
                    context.read<PuzzleBloc>().add(
                          const PuzzleInitialized(shufflePuzzle: true),
                        );
                    // }

                    unawaited(_audioPlayer.replay());
                  },
            textColor: isLoading ? theme.defaultColor : null,
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
