import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';

import '../../core/models/episode.dart';
import '../../core/models/episode_library.dart';
import '../../core/models/puzzle_l10n.dart';
import '../../core/models/signature_entry.dart';
import '../../core/models/variation.dart' show canonicalPuzzleId;
import '../../core/storage/progress_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/motion.dart';
import '../../l10n/gen/app_localizations.dart';
import '../familiarity/familiar_cue.dart';
import '../familiarity/familiarity_first_seen_overlay.dart';
import '../records/record_symbols.dart';
import '../records/record_unlock_overlay.dart';
import '../settings/language_picker.dart';
import '../signatures/first_bookmark_hint_overlay.dart';
import '../signatures/signature_bookmark_glyph.dart';
import 'episode_completion_sheet.dart';
import 'game_controller.dart';
import 'game_state.dart';
import 'rescue_screen_pop_result.dart';
import 'widgets/board_widget.dart';
import 'widgets/footer_button.dart';
import 'widgets/headline_text.dart';
import 'widgets/intro_overlay.dart';
import 'widgets/saved_badge.dart';
import 'widgets/status_bar.dart';

class RescueScreen extends StatefulWidget {
  const RescueScreen({
    super.key,
    required this.store,
    this.controller,
    this.episode,
  });

  final ProgressStore? store;

  /// Optional injected controller — a debug/testing seam used by the Phase-29
  /// screenshot harness to render a pre-driven game state. When null (the
  /// shipping path via main.dart), the screen creates and owns its own.
  final GameController? controller;

  /// P3 — the episode this screen plays. When null, the controller picks
  /// `EpisodeLibrary.first` (ep1) as a safe fallback.
  final Episode? episode;

  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen> {
  late final GameController _game;
  late final bool _ownsController;
  // R1B — accumulator for every record unlocked during this session, in
  // chronological order. Used as the pop-result payload to Home.
  final List<String> _sessionRecordIds = <String>[];
  // R1B — records that arrived AT the most recent finale-rescue commit.
  // These render inline in the EpisodeCompletionSheet (NOT as overlays).
  // Drained when the sheet pops or when the controller leaves the finale
  // state.
  final List<String> _finaleRecordIds = <String>[];
  // R1B — mid-rescue overlay queue. Records that arrived outside a finale
  // commit are surfaced as banner toasts one at a time.
  final List<String> _overlayQueue = <String>[];
  String? _activeOverlayId; // currently fading-in / hold / fading-out
  bool _initialUnlockedRecordsEmpty = false;
  bool _firstOverlayHasFired = false;
  // PR 2 — one-time first-bookmark hint. Flipped to true when the player
  // adds their very first Signature; the FirstBookmarkHintOverlay clears
  // it via onDismissed after the fade-out completes.
  bool _showFirstBookmarkHint = false;
  // PR 3 — one-time first-recognition hint. Flipped to true the first
  // time the player re-encounters a previously-solved canonical id;
  // the FamiliarityFirstSeenOverlay clears it via onDismissed after
  // the fade-out completes.
  bool _showFirstFamiliarityHint = false;

  @override
  void initState() {
    super.initState();
    _game =
        widget.controller ??
        GameController(store: widget.store, episode: widget.episode);
    _ownsController = widget.controller == null;
    // R1B — snapshot for "first ever record" detection. If the player has
    // never unlocked any record before, the first overlay this session gets
    // the special italic "A page has been written." eyebrow.
    _initialUnlockedRecordsEmpty =
        (widget.store?.unlockedRecordsSet ?? const <String>{}).isEmpty;
    _game.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    _game.removeListener(_handleControllerChange);
    if (_ownsController) _game.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    // R1B — only consume records when a fresh rescue commit lands. The
    // controller's rescued state is the cleanest signal: it transitions
    // from non-rescued → rescued once per successful commit.
    if (_game.state != GameState.rescued) return;
    // PR 3 Familiarity — trigger the one-time first-recognition hint
    // BEFORE the records-just-unlocked guard, so the check runs on every
    // rescued transition, not only on those with new records.
    _maybeShowFirstFamiliarityHint();
    final justUnlocked = _game.recordsJustUnlocked;
    if (justUnlocked.isEmpty) return;
    // Skip if we've already consumed this exact set (a no-op rebuild).
    final newOnes = justUnlocked
        .where((id) => !_sessionRecordIds.contains(id))
        .toList();
    if (newOnes.isEmpty) return;
    _sessionRecordIds.addAll(newOnes);
    if (_game.isEpisodeFinale) {
      // Records earned at the finale go to the sheet's inline section.
      setState(() => _finaleRecordIds.addAll(newOnes));
    } else {
      // Mid-rescue records queue as banner toasts.
      setState(() => _overlayQueue.addAll(newOnes));
      _tryShowNextOverlay();
    }
  }

  void _tryShowNextOverlay() {
    if (_activeOverlayId != null) return;
    if (_overlayQueue.isEmpty) return;
    setState(() {
      _activeOverlayId = _overlayQueue.removeAt(0);
    });
  }

  void _handleOverlayDismissed() {
    _firstOverlayHasFired = true;
    if (!mounted) return;
    setState(() => _activeOverlayId = null);
    // Brief gap between queued overlays.
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _tryShowNextOverlay();
    });
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
          // P3 — when the last rescue of a canonical/master episode lands, the
          // footer becomes a "Back to Home" CTA and the tap pops the navigator
          // rather than routing through the controller (no auto-rotation).
          final isEpisodeFinale = _game.isEpisodeFinale;
          final buttonLabel = switch (_game.state) {
            // When the finale lands, the EpisodeCompletionSheet (rendered as a
            // Stack overlay below) owns the celebration + the pop; the footer
            // button is hidden behind the sheet's backdrop dim. We keep the
            // label assignment so the underlying button has a valid string
            // during the 280ms sheet fade-in.
            GameState.rescued when isEpisodeFinale => l.episodeCompleteFooter,
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
                                  // Developer reset surface — visible only in
                                  // debug + profile builds. In release the
                                  // callback is null and the long-press is
                                  // inert exactly as before. A confirmation
                                  // dialog guards against accidental wipes
                                  // during QA testing; on confirm we pop back
                                  // to Home so Home re-reads the fresh store.
                                  onReset: !kReleaseMode
                                      ? _confirmAndReset
                                      : null,
                                  complete: _game.allComplete,
                                ),
                              ],
                              // PR 2 — bookmark glyph. Only on the rescued
                              // state (no rescue to keep before the move
                              // lands), only when there's a store to write
                              // to. Visually SECONDARY to SAVED: smaller,
                              // dim, no mint accent. 12dp gap so it sits a
                              // bit removed from the SavedBadge cluster.
                              if (isRescued && widget.store != null) ...[
                                const SizedBox(width: 12),
                                SignatureBookmarkGlyph(
                                  isSaved: widget.store!.isSignatureSaved(
                                    canonicalPuzzleId(puzzle.id),
                                  ),
                                  onTap: _onBookmarkTap,
                                ),
                              ],
                              // C5 — tiny language affordance, always visible
                              // on the rescue screen (hidden behind the intro
                              // overlay during first-run).
                              const SizedBox(width: 4),
                              const LanguagePickerButton(),
                            ],
                          ),
                          // PR 3 — Familiarity ambient cue. Quiet
                          // observational annotation between the
                          // transactional status row and the rescued
                          // headline. Only on rescued + previously-
                          // solved; non-familiar rescues keep the
                          // original 30dp spacing unchanged.
                          if (isRescued && _game.wasPreviouslySolvedAtStart)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: FamiliarCue(),
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
                              focusSquare: puzzle.tappableSquare,
                              focusCueIsAmbient: !_game.isOnboarding,
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
                            onTap: isEpisodeFinale
                                ? () => _popWithResult(
                                    context,
                                    finishedEpisode: true,
                                  )
                                : _game.onPrimaryAction,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // R1B — mid-rescue record unlock banner. Non-blocking; renders
              // above the FooterButton, dismisses itself after ~2.5s.
              if (_activeOverlayId != null)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 84,
                  child: _buildOverlay(context, l, _activeOverlayId!),
                ),
              // PR 2 — first-bookmark inline hint. One-time per device.
              // Fires immediately after the player taps the bookmark glyph
              // for the very first time. Positioned slightly higher than
              // the record unlock band so the rare simultaneous case is
              // visually distinct. Non-interactive (the overlay is wrapped
              // in IgnorePointer internally).
              if (_showFirstBookmarkHint)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 170,
                  child: FirstBookmarkHintOverlay(
                    onDismissed: _handleFirstBookmarkHintDismissed,
                  ),
                ),
              // PR 3 — first-recognition inline hint. One-time per device.
              // Fires the first time the player re-encounters a previously-
              // solved canonical id. Positioned HIGHER than the bookmark
              // hint so if both fire on the same rescued screen (rare),
              // they stack vertically rather than overlap. Non-interactive
              // (IgnorePointer is internal to the overlay).
              if (_showFirstFamiliarityHint)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 250,
                  child: FamiliarityFirstSeenOverlay(
                    onDismissed: _handleFirstFamiliarityHintDismissed,
                  ),
                ),
              // G1.1 — Episode Completion Sheet. Mounts over the rescue UI
              // when the player reaches the canonical / master episode finale;
              // its Continue CTA owns the Navigator.maybePop<RescueScreenPopResult>(...)
              // — the same pop signal P3.1 wires to Home's auto-focus + persistence,
              // now extended with the records earned at this finale.
              if (isEpisodeFinale)
                Positioned.fill(
                  child: _buildCompletionSheet(context, l, _game.episode),
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

  Widget _buildCompletionSheet(
    BuildContext context,
    AppL10n l,
    Episode episode,
  ) {
    final isTrilogy = episode.id == EpisodeLibrary.ep3.id;
    final finaleRows = <CompletionSheetRecordRow>[
      for (final id in _finaleRecordIds)
        CompletionSheetRecordRow(
          title: recordTitleFor(id, l),
          description: recordDescriptionUnlockedFor(id, l),
        ),
    ];
    return EpisodeCompletionSheet(
      eyebrow: isTrilogy
          ? l.episodeSheetTrilogyEyebrow
          : l.episodeSheetCompleteEyebrow,
      episodeLabel: l.episodeSheetEpisodeLabel(episode.number),
      title: _episodeTitle(l, episode),
      rescuesCount: l.episodeSheetRescuesCount(episode.puzzleCount),
      continueLabel: l.episodeSheetContinue,
      trilogyUnlockLabel: isTrilogy ? l.episodeSheetTrilogyUnlock : null,
      recordUnlockEyebrow: finaleRows.isEmpty ? null : l.recordUnlockEyebrow,
      unlockedRecords: finaleRows,
      onContinue: () => _popWithResult(context, finishedEpisode: true),
    );
  }

  String _episodeTitle(AppL10n l, Episode episode) {
    switch (episode.id) {
      case 'ep1-strike-back':
        return l.episodeEp1Title;
      case 'ep2-end-the-threat':
        return l.episodeEp2Title;
      case 'ep3-hold-the-line':
        return l.episodeEp3Title;
      case 'ep4-the-other-side':
        return l.episodeEp4Title;
      case 'ep5-endless-rescue':
        return l.episodeEp5Title;
    }
    return '';
  }

  /// R1B — packs the session record list + finale flag into the
  /// `RescueScreenPopResult` and pops the navigator. All explicit pop sites
  /// (finale CTA, completion-sheet Continue) route through here.
  void _popWithResult(BuildContext context, {required bool finishedEpisode}) {
    Navigator.of(context).maybePop<RescueScreenPopResult>(
      RescueScreenPopResult(
        finishedEpisode: finishedEpisode,
        newlyUnlockedRecordIds: List<String>.unmodifiable(_sessionRecordIds),
      ),
    );
  }

  /// Developer reset surface — shows a destructive-action confirmation,
  /// wipes all persisted progress on confirm, then pops back to Home so
  /// Home re-reads the now-empty store and renders the first-run state.
  /// Wired only via SavedBadge long-press in debug + profile builds
  /// (release builds receive a null `onReset` and are unaffected).
  Future<void> _confirmAndReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset all progress?'),
        content: const Text(
          'This will erase every puzzle completed, all signatures, '
          'records, streaks, and onboarding state. This cannot be undone.\n\n'
          'Developer tool — not intended for normal play.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _game.resetProgress();
    if (!mounted) return;
    Navigator.of(context).maybePop<RescueScreenPopResult>();
  }

  /// PR 2 — toggle the current puzzle's Signature membership. Reads the
  /// current saved state via [ProgressStore.isSignatureSaved] (canonical-
  /// id based) and either adds or removes. On the player's very first
  /// add ever (transition from empty signatures + first-bookmark-hint-
  /// flag not seen → has one), mounts the [FirstBookmarkHintOverlay]
  /// and marks the flag so it never fires again.
  void _onBookmarkTap() {
    final store = widget.store;
    if (store == null) return;
    final puzzle = _game.currentPuzzle;
    final canonical = canonicalPuzzleId(puzzle.id);
    final episode = _game.episode;
    final wasSaved = store.isSignatureSaved(canonical);
    if (wasSaved) {
      unawaited(store.removeSignature(canonical));
    } else {
      final isEndless = episode.kind == EpisodeKind.endless;
      unawaited(
        store.addSignature(
          SignatureEntry(
            canonicalPuzzleId: canonical,
            encounteredPuzzleId: puzzle.id,
            episodeId: episode.id,
            adoptedAt: DateTime.now(),
            endlessSeed: isEndless ? _game.sessionSeed : null,
            endlessMirrored: isEndless ? puzzle.id.contains('#mirror') : null,
          ),
        ),
      );
      // Trigger the one-time first-bookmark hint if (a) the player had
      // never bookmarked anything before, and (b) the inline hint flag
      // has never been marked. We check both because PR 1's storage
      // tracks the flag independently of the signatures list — a player
      // could have bookmarked once, removed it, and the flag would still
      // be true (the hint has been seen). We only want the hint on the
      // genuine first-ever bookmark.
      if (!store.hasSeenSignaturesFirstBookmarkHint) {
        unawaited(store.markSignaturesFirstBookmarkHintSeen());
        setState(() => _showFirstBookmarkHint = true);
      }
    }
    // Re-render the glyph (and any consumers of isSignatureSaved).
    setState(() {});
  }

  void _handleFirstBookmarkHintDismissed() {
    if (!mounted) return;
    setState(() => _showFirstBookmarkHint = false);
  }

  /// PR 3 Familiarity — fire the one-time first-recognition inline hint.
  /// Gated on (a) the current puzzle being a previously-solved canonical,
  /// (b) the store flag not yet marked, and (c) the local flag not
  /// already showing. Marks the persisted flag immediately so a
  /// mid-fade screen-close does not re-fire on the next rescued state.
  void _maybeShowFirstFamiliarityHint() {
    if (!_game.wasPreviouslySolvedAtStart) return;
    final store = widget.store;
    if (store == null) return;
    if (store.hasSeenFirstFamiliarityHint) return;
    if (_showFirstFamiliarityHint) return;
    unawaited(store.markFirstFamiliarityHintSeen());
    setState(() => _showFirstFamiliarityHint = true);
  }

  void _handleFirstFamiliarityHintDismissed() {
    if (!mounted) return;
    setState(() => _showFirstFamiliarityHint = false);
  }

  /// R1B — renders the active mid-rescue overlay for [recordId]. The first
  /// overlay this session uses the special "A page has been written."
  /// variant iff the player had never earned a record before mounting.
  Widget _buildOverlay(BuildContext context, AppL10n l, String recordId) {
    final isFirstEver = _initialUnlockedRecordsEmpty && !_firstOverlayHasFired;
    return RecordUnlockOverlay(
      key: ValueKey('record-unlock-overlay-$recordId'),
      eyebrow: isFirstEver
          ? l.recordUnlockEyebrowFirstEver
          : l.recordUnlockEyebrow,
      eyebrowIsFirstEver: isFirstEver,
      title: recordTitleFor(recordId, l),
      description: recordDescriptionUnlockedFor(recordId, l),
      onDismissed: _handleOverlayDismissed,
    );
  }
}
