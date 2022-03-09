import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rive/rive.dart';
import 'package:very_good_slide_puzzle/app/view/app.dart';
import 'package:very_good_slide_puzzle/audio_control/audio_control.dart';
import 'package:very_good_slide_puzzle/helpers/helpers.dart';
import 'package:very_good_slide_puzzle/l10n/l10n.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/models/models.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/walkie/walkie.dart';

abstract class _TileSize {
  static double small = 75;
  static double medium = 100;
  static double large = 112;
}

/// {@template walkie_puzzle_tile}
/// Displays the puzzle tile associated with [tile]
/// based on the puzzle [state].
/// {@endtemplate}
class WalkiePuzzleTile extends StatefulWidget {
  /// {@macro walkie_puzzle_tile}
  const WalkiePuzzleTile({
    Key? key,
    required this.tile,
    required this.state,
    AudioPlayerFactory? audioPlayer,
  })  : _audioPlayerFactory = audioPlayer ?? getAudioPlayer,
        super(key: key);

  /// The tile to be displayed.
  final Tile tile;

  /// The state of the puzzle.
  final PuzzleState state;

  final AudioPlayerFactory _audioPlayerFactory;

  @override
  State<WalkiePuzzleTile> createState() => WalkiePuzzleTileState();
}

/// The state of [WalkiePuzzleTile].
@visibleForTesting
class WalkiePuzzleTileState extends State<WalkiePuzzleTile>
    with SingleTickerProviderStateMixin {
  final _widgetKey = GlobalKey();

  AudioPlayer? _audioPlayer;
  late final Timer _timer;

  late Artboard _riveArtboard;

  void _loadRiveFile() {
    // Load the RiveFile from the binary data.
    final file = RiveFile.import(RiveProvider.of(context).blueWalkie!);

    // The artboard is the root of the animation and gets drawn in the
    // Rive widget.
    final artboard = file.mainArtboard;
    _addRiveAnimationControllers(artboard);
    _riveArtboard = artboard;
  }

  late StateMachineController? _mainStateMachineController;
  late SMIInput<double>? _pupilXInput;
  late SMIInput<double>? _pupilYInput;
  late SMITrigger? _trottingOn;
  late SMITrigger? _trottingOff;
  late SMITrigger? _trottingLeftOn;
  late SMITrigger? _trottingLeftOff;
  late SMITrigger? _jumpOn;
  late SMITrigger? _fallOn;
  late SMIBool? _index;
  late SMIBool? _float;
  late SMIBool? _isCorrectPosition;
  late SMIBool? _ready;
  late StreamSubscription _mouseEventSubscription;
  late double _widgetX;
  late double _widgetY;
  late double _xAlign;
  late double _yAlign;

  /// Move animation duration
  int _alignAnimationDuration = 1000;

  /// Move animation curve
  Curve _alignAnimationCurve = Curves.linear;

  void _addRiveAnimationControllers(Artboard artboard) {
    _mainStateMachineController = StateMachineController.fromArtboard(
      artboard,
      'main',
    );
    if (_mainStateMachineController != null) {
      artboard.addController(_mainStateMachineController!);
    }
    _pupilXInput = _mainStateMachineController?.findInput<double>('pupil_x');
    _pupilYInput = _mainStateMachineController?.findInput<double>('pupil_y');
    _trottingOn =
        _mainStateMachineController?.findSMI<SMITrigger>('trottingOn');
    _trottingOff =
        _mainStateMachineController?.findSMI<SMITrigger>('trottingOff');
    _trottingLeftOn =
        _mainStateMachineController?.findSMI<SMITrigger>('trottingLeftOn');
    _trottingLeftOff =
        _mainStateMachineController?.findSMI<SMITrigger>('trottingLeftOff');
    _jumpOn = _mainStateMachineController?.findSMI<SMITrigger>('jumpOn');
    _fallOn = _mainStateMachineController?.findSMI<SMITrigger>('fallOn');
    _index =
        _mainStateMachineController?.findSMI<SMIBool>('${widget.tile.value}');
    _float = _mainStateMachineController?.findSMI<SMIBool>('float');
    _isCorrectPosition =
        _mainStateMachineController?.findSMI<SMIBool>('correct');
    _ready = _mainStateMachineController?.findSMI<SMIBool>('ready');
    setState(() {
      _index?.change(true);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
    // Delay the initialization of the audio player for performance reasons,
    // to avoid dropping frames when the theme is changed.
    _timer = Timer(const Duration(seconds: 1), () {
      _audioPlayer = widget._audioPlayerFactory()
      ..setAsset('assets/audio/tile_move.mp3');
    });
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _getWidgetInfo();
      _initMouseEventListener();
    });
  }

  void _initMouseEventListener() {
    _mouseEventSubscription = MouseEventsProvider.of(context)
        .mouseEventStream
        .listen(_mouseEventDispatch);
  }

  void _mouseEventDispatch(MouseEvent event) {
    switch (event.type) {
      case MouseEventType.hover:
        _hoverEventHandler(event);
        break;
      case MouseEventType.enter:
        _enterEventHandler(event);
        break;
      case MouseEventType.exit:
        _exitEventHandler(event);
        break;
    }
  }

  void _hoverEventHandler(MouseEvent event) {
    _updatePupilsPosition(event);
    // log('type: ${event.type} x: ${event.x.floor()}, y: ${event.y.floor()}');
  }

  void _enterEventHandler(MouseEvent event) {
    log('type: ${event.type} x: ${event.x.floor()}, y: ${event.y.floor()}');
  }

  void _exitEventHandler(MouseEvent event) {
    log('type: ${event.type} x: ${event.x.floor()}, y: ${event.y.floor()}');
  }

  @override
  void didUpdateWidget(covariant WalkiePuzzleTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _activateAnimation();
  }

  Future<void> _activateAnimation() async {
    for (final movedTile in widget.state.puzzle.movedTiles) {
      if (widget.tile.value == movedTile.tile.value) {
        if (movedTile.moveDirection == MoveDirection.left) {
          _alignAnimationCurve = Curves.linear;
          _alignAnimationDuration = 1000;
          _trottingLeftOn?.fire();
        }
        if (movedTile.moveDirection == MoveDirection.right) {
          _alignAnimationCurve = Curves.linear;
          _alignAnimationDuration = 1000;
          _trottingOn?.fire();
        }
        if (movedTile.moveDirection == MoveDirection.top) {
          _alignAnimationCurve =
              const Interval(0.5, 1, curve: Curves.easeOutBack);
          _alignAnimationDuration = 1000;
          _jumpOn?.fire();
        }
        if (movedTile.moveDirection == MoveDirection.bottom) {
          _alignAnimationDuration = 500;
          _alignAnimationCurve = Curves.easeInExpo;
          _fallOn?.fire();
        }
      }
    }
  }

  void _getWidgetInfo() {
    final renderBox =
        _widgetKey.currentContext?.findRenderObject() as RenderBox;

    final size = renderBox.size; // or _widgetKey.currentContext?.size

    final offset = renderBox.localToGlobal(Offset.zero);
    _widgetX = offset.dx + size.width / 2;
    _widgetY = offset.dy + size.height / 2;
  }

  void _updatePupilsPosition(MouseEvent event) {
    final distanceFromEyesToCursorX = event.x - _widgetX;
    final distanceFromEyesToCursorY = event.y - _widgetY;
    final angle = math.atan2(
      distanceFromEyesToCursorY,
      distanceFromEyesToCursorX,
    );
    final yPos = math.sin(angle);
    final xPos = math.cos(angle);
    _pupilYInput?.change(-yPos * 100);
    _pupilXInput?.change(xPos * 100);
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioPlayer?.dispose();
    _mouseEventSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.state.puzzle.getDimension();
    final status = context.select((WalkiePuzzleBloc bloc) => bloc.state.status);
    final secondsToBegin =
        context.select((WalkiePuzzleBloc bloc) => bloc.state.secondsToBegin);
    final hasStarted = status == WalkiePuzzleStatus.started;
    final puzzleIncomplete =
        widget.state.puzzleStatus == PuzzleStatus.incomplete;
    if (status == WalkiePuzzleStatus.loading) {
      _alignAnimationCurve = Curves.linear;
      if (secondsToBegin == 3) {
        _xAlign = (widget.tile.currentPosition.x - 1) / (size - 1);
        _yAlign = -5;
        _alignAnimationDuration = math.Random().nextInt(1500) + 1500;
      } else {
        _alignAnimationDuration = math.Random().nextInt(1000) + 1000;
        _xAlign = (widget.tile.currentPosition.x - 1) / (size - 1);
        _yAlign = (widget.tile.currentPosition.y - 1) / (size - 1);
      }
    } else {
      _xAlign = (widget.tile.currentPosition.x - 1) / (size - 1);
      _yAlign = (widget.tile.currentPosition.y - 1) / (size - 1);
    }

    final canPress = hasStarted && puzzleIncomplete;
    return AudioControlListener(
      audioPlayer: _audioPlayer,
      child: AnimatedAlign(
        alignment: FractionalOffset(
          _xAlign,
          _yAlign,
        ),
        duration: Duration(milliseconds: _alignAnimationDuration),
        curve: _alignAnimationCurve,
        onEnd: () {
          _trottingOff?.fire();
          _trottingLeftOff?.fire();
          if (widget.tile.correctPosition == widget.tile.currentPosition) {
            _isCorrectPosition?.change(true);
          } else {
            _isCorrectPosition?.change(false);
          }
          _getWidgetInfo();
        },
        child: ResponsiveLayoutBuilder(
          small: (_, child) => SizedBox.square(
            key: Key('walkie_puzzle_tile_small_${widget.tile.value}'),
            dimension: _TileSize.small,
            child: child,
          ),
          medium: (_, child) => SizedBox.square(
            key: Key('walkie_puzzle_tile_medium_${widget.tile.value}'),
            dimension: _TileSize.medium,
            child: child,
          ),
          large: (_, child) => SizedBox.square(
            key: Key('walkie_puzzle_tile_large_${widget.tile.value}'),
            dimension: _TileSize.large,
            child: child,
          ),
          child: (_) => MouseRegion(
            onEnter: (_) {
              if (canPress) {
                _float?.change(true);
              }
            },
            onExit: (_) {
              if (canPress) {
                _float?.change(false);
              }
            },
            child: IconButton(
              key: _widgetKey,
              padding: EdgeInsets.zero,
              onPressed: canPress
                  ? () {
                      context.read<PuzzleBloc>().add(TileTapped(widget.tile));
                      unawaited(_audioPlayer?.replay());
                    }
                  : null,
              icon: Semantics(
                label: context.l10n.puzzleTileLabelText(
                  widget.tile.value.toString(),
                  widget.tile.currentPosition.x.toString(),
                  widget.tile.currentPosition.y.toString(),
                ),
                child: Rive(
                  artboard: _riveArtboard,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
