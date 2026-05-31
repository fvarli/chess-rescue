import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../core/models/puzzle_l10n.dart';
import '../../core/storage/progress_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/motion.dart';
import '../../l10n/gen/app_localizations.dart';
import '../settings/language_picker.dart';
import 'game_controller.dart';
import 'game_state.dart';
import 'widgets/board_widget.dart';
import 'widgets/footer_button.dart';
import 'widgets/headline_text.dart';
import 'widgets/intro_overlay.dart';
import 'widgets/saved_badge.dart';
import 'widgets/status_bar.dart';

class RescueScreen extends StatefulWidget {
  const RescueScreen({super.key, required this.store, this.controller});

  final ProgressStore? store;

  /// Optional injected controller — a debug/testing seam used by the Phase-29
  /// screenshot harness to render a pre-driven game state. When null (the
  /// shipping path via main.dart), the screen creates and owns its own.
  final GameController? controller;

  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen> {
  late final GameController _game;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _game = widget.controller ?? GameController(store: widget.store);
    _ownsController = widget.controller == null;
  }

  @override
  void dispose() {
    if (_ownsController) _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListenableBuilder(
        listenable: _game,
        builder: (context, _) {
          final l = AppL10n.of(context)!;
          final isRescued = _game.state == GameState.rescued;
          final puzzle = _game.currentPuzzle;
          final puzzleCopy = puzzleCopyFor(puzzle, l);
          final sequenceComplete =
              isRescued && _game.allComplete && !_game.hasNext;
          final buttonLabel = switch (_game.state) {
            GameState.rescued =>
              _game.hasNext ? l.footerNextPuzzle : l.footerAgain,
            GameState.failed => l.footerTryAgain,
            _ => l.footerReset,
          };
          // Status pill message: localized per-puzzle copy for danger/selected;
          // the controller's transient hardcoded messages for failed/rescued
          // ("▮ Still trapped" / "◐ Attack broken") stay EN — out of C3 scope.
          final statusMessage = switch (_game.state) {
            GameState.danger || GameState.selected => puzzleCopy.statusText,
            _ => _game.statusMsg,
          };
          return Stack(
            fit: StackFit.expand,
            children: [
              AnimatedContainer(
                duration: MotionTokens.gradientTransition,
                curve: MotionTokens.standard,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, isRescued ? -0.1 : -0.2),
                    radius: 0.9,
                    colors: [
                      isRescued
                          ? AppColors.backdropRescue
                          : AppColors.backdropDanger,
                      AppColors.bg,
                    ],
                    stops: const [0.0, 0.8],
                  ),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, c) {
                    // Board stays dominant on phones; shrinks gracefully on
                    // short screens. hPad matches the Column's horizontal
                    // padding (16+16). chromeReserve covers the status row,
                    // headline, two-line completion hint, footer and gaps at
                    // the clamped 1.35x text scale, so the Column never
                    // overflows. Tested assumption: portrait phones, no scroll.
                    const double hPad = 16, chromeReserve = 260;
                    const double boardMin = 200, boardMax = 360;
                    final size = math
                        .min(c.maxWidth - hPad * 2, c.maxHeight - chromeReserve)
                        .clamp(boardMin, boardMax);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Expanded caps the pill to (width − badge) so a
                              // long status message ellipsizes instead of
                              // clipping the right edge; the badge stays pinned
                              // right and fully visible.
                              Expanded(
                                child: StatusBar(
                                  state: _game.state,
                                  message: statusMessage,
                                  counter: l.puzzleCounter(
                                    _game.puzzleNumber,
                                    _game.puzzleCount,
                                  ),
                                ),
                              ),
                              if (_game.completedCount > 0) ...[
                                const SizedBox(width: 12),
                                SavedBadge(
                                  count: _game.completedCount,
                                  // Debug-only affordance: inert in release.
                                  onReset: kDebugMode
                                      ? _game.resetProgress
                                      : null,
                                  complete: _game.allComplete,
                                ),
                              ],
                              // C5 — tiny language affordance, always visible
                              // on the rescue screen (hidden behind the intro
                              // overlay during first-run).
                              const SizedBox(width: 4),
                              const LanguagePickerButton(),
                            ],
                          ),
                          const SizedBox(height: 30),
                          HeadlineText(
                            state: _game.state,
                            hasSelection: _game.selected != null,
                          ),
                          const Spacer(),
                          AnimatedSwitcher(
                            duration: MotionTokens.headlineFade,
                            switchInCurve: MotionTokens.standard,
                            switchOutCurve: Curves.easeIn,
                            child: BoardWidget(
                              key: ValueKey(puzzle.id),
                              size: size,
                              pieces: _game.pieces,
                              selected: _game.selected,
                              legalSquares: _game.legalSquares,
                              state: _game.state,
                              threatenedKing: puzzle.threatenedKing,
                              rescueTo: puzzle.rescueTo,
                              commitInFlight: _game.commitInFlight,
                              resetInFlight: _game.resetInFlight,
                              onTapSquare: _game.handleSquare,
                              focusSquare: _game.isOnboarding
                                  ? puzzle.tappableSquare
                                  : null,
                              extendedSettle: _game.isOnboarding,
                            ),
                          ),
                          const SizedBox(height: 28),
                          HintText(
                            state: _game.state,
                            hasSelection: _game.selected != null,
                            dangerHint: puzzleCopy.dangerHint,
                            failureHint: puzzleCopy.failureHint,
                            successExplanation: puzzleCopy.successExplanation,
                            onboarding: _game.isOnboarding,
                            complete: sequenceComplete,
                          ),
                          const Spacer(),
                          FooterButton(
                            state: _game.state,
                            label: buttonLabel,
                            onTap: _game.onPrimaryAction,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // First-run intro overlay (topmost). Cross-fades out when its CTA
              // dismisses it, revealing the danger cold open underneath with the
              // focus cue intact. Absent when there's no store (harness/degraded).
              AnimatedSwitcher(
                duration: MotionTokens.gradientTransition,
                switchInCurve: MotionTokens.standard,
                switchOutCurve: Curves.easeIn,
                child: _game.showIntro
                    ? IntroOverlay(
                        key: const ValueKey('intro'),
                        onStart: _game.dismissIntro,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }
}
