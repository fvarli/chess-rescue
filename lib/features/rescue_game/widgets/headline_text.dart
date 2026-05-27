import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../game_state.dart';

class HeadlineText extends StatelessWidget {
  const HeadlineText({
    super.key,
    required this.state,
    required this.hasSelection,
  });

  final GameState state;
  final bool hasSelection;

  String get _text => switch (state) {
    GameState.rescued => 'Rescued.',
    GameState.failed => 'Not the move.',
    GameState.selected => 'Where will it go?',
    GameState.danger => hasSelection ? 'Where will it go?' : 'Save the king.',
  };

  Color get _color =>
      state == GameState.rescued ? AppColors.rescue : AppColors.text;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Text(
        _text,
        key: ValueKey(_text),
        style: AppText.headline.copyWith(color: _color),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class HintText extends StatelessWidget {
  const HintText({super.key, required this.state, required this.hasSelection});

  final GameState state;
  final bool hasSelection;

  @override
  Widget build(BuildContext context) {
    final (text, style) = switch (state) {
      GameState.rescued => (
        'KNIGHT TO F6 · CHECK & FORK',
        AppText.mono.copyWith(color: AppColors.rescue, letterSpacing: 2.1),
      ),
      GameState.failed => (
        "That move doesn't break the attack. Look for a check.",
        AppText.body,
      ),
      GameState.selected => ('Tap a highlighted square to move.', AppText.body),
      GameState.danger => (
        hasSelection
            ? 'Tap a highlighted square to move.'
            : 'Tap a white piece to see its moves.',
        AppText.body,
      ),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Text(
        text,
        key: ValueKey(text),
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }
}
