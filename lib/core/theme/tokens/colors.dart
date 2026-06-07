import 'package:flutter/material.dart';

/// Semantic color tokens — the foundation layer for v1.2.0 "Threshold".
///
/// Every future PR consumes [ColorTokens] instead of raw hex values or the
/// legacy [AppColors] namespace. The values themselves stay locked to the
/// shipped 1.1.1 palette so this PR has zero visible impact; migration of
/// existing widgets happens incrementally in later PRs.
///
/// Naming convention: `<role><Variant>` (e.g. `dangerPrimary`, `dangerGlow`).
/// Roles map directly to the emotional loop: **panic → relief**.
abstract final class ColorTokens {
  // ── Danger family — coral spine ─────────────────────────────────────────
  /// Primary coral. Threat indicators, danger glows at full intensity.
  static const Color dangerPrimary = Color(0xFFFF5A4C);

  /// Coral at 60% alpha — for halos, soft fills, ambient danger pulses.
  static const Color dangerGlow = Color(0x99FF5A4C);

  /// Coral at 10% alpha — for atmospheric background washes on danger
  /// surfaces (briefing cards, Daily Rescue intro card).
  static const Color dangerBackground = Color(0x1AFF5A4C);

  // ── Relief family — mint spine ──────────────────────────────────────────
  /// Primary mint. Rescue confirmation, success indicators, CTA tint.
  static const Color reliefPrimary = Color(0xFF5EE2C0);

  /// Mint at 60% alpha — for rescue halos, ambient relief pulses.
  static const Color reliefGlow = Color(0x995EE2C0);

  /// Mint at 10% alpha — for atmospheric background washes on relief
  /// surfaces (Success state, Records journal accents).
  static const Color reliefBackground = Color(0x1A5EE2C0);

  // ── Surface stack (three depth layers) ──────────────────────────────────
  /// Deepest field — the base background for every screen.
  static const Color surfacePrimary = Color(0xFF0D0E12);

  /// Mid layer — briefing cards, lower-elevation surfaces.
  static const Color surfaceSecondary = Color(0xFF161821);

  /// Top layer — raised cards (Today's puzzle, hero containers).
  static const Color surfaceElevated = Color(0xFF1D2030);

  // ── Text ─────────────────────────────────────────────────────────────────
  /// Full-strength body text and headlines.
  static const Color textPrimary = Color(0xFFEAEAF2);

  /// 55% alpha — sub-text, captions, descriptive copy.
  static const Color textSecondary = Color(0x8CEAEAF2);

  // ── System ──────────────────────────────────────────────────────────────
  /// Hairline borders, separators, card outlines.
  static const Color divider = Color(0xFF2A2C39);

  /// Disabled state foreground.
  static const Color disabled = Color(0xFF4A4D5A);

  /// Modal scrim overlay (55% black).
  static const Color overlay = Color(0x8C000000);

  /// Standard drop shadow color (25% black).
  static const Color shadow = Color(0x40000000);

  // ── Board materials ─────────────────────────────────────────────────────
  /// Light board squares — warm slate. Anchor for premium board look.
  static const Color boardLight = Color(0xFF3E4250);

  /// Dark board squares — deep charcoal with a slight L lift so the
  /// silhouettes of dark pieces (`pieceDark #0C0D14`) read against the
  /// surface without needing extra shadow.
  static const Color boardDark = Color(0xFF181B26);

  /// Grid line tint — 2.5% white. Whispers between squares once each
  /// square carries its own subtle gradient.
  static const Color boardGridLine = Color(0x06FFFFFF);

  /// Board outer drop shadow (55% black). Separate from the generic
  /// `shadow` token (25%) which is for inline card elevation.
  static const Color boardShadow = Color(0x8C000000);

  // ── Piece materials ─────────────────────────────────────────────────────
  /// Light pieces — near-white ivory.
  static const Color pieceLight = Color(0xFFEAEAF2);

  /// Dark pieces — near-black ebony.
  static const Color pieceDark = Color(0xFF0C0D14);

  /// Stroke on light pieces — 55% alpha dark for soft contour.
  static const Color pieceLightStroke = Color(0x8C0C0D14);

  /// Stroke on dark pieces — 22% alpha light, hairline-faint so the
  /// silhouette reads from the gradient, not from a hard outline.
  static const Color pieceDarkStroke = Color(0x38EAEAF2);

  /// Soft contact shadow under every piece (40% black). Uniform across
  /// light and dark pieces; tunable here without touching the painter.
  static const Color pieceFloorShadow = Color(0x66000000);

  /// Top sheen on light pieces (8% white) — subtle polished-resin cue.
  static const Color pieceLightHighlight = Color(0x14FFFFFF);

  /// Top sheen on dark pieces (12% white) — slightly stronger so the
  /// carved body reads against the deep-charcoal board.
  static const Color pieceDarkHighlight = Color(0x1FFFFFFF);

  // ── Accents ─────────────────────────────────────────────────────────────
  /// Mint at 35% alpha — for coordinate labels and quiet accent strokes.
  /// Designed to recede; never used for primary signal.
  static const Color coordinateAccent = Color(0x595EE2C0);

  /// Tertiary muted text — record metadata, timestamps, system labels.
  static const Color muted = Color(0xFF8E8FA0);
}
