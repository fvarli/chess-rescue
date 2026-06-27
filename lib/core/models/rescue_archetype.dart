/// The Phase 19A rescue archetype taxonomy — the emotional category of a rescue
/// (its feeling + rescue-logic shape), independent of geometry.
/// See docs/rescue-archetypes.md for the full per-archetype spec.
enum RescueArchetype {
  counterCheck, // P1 Knight rescue (real) — hit back with check
  captureAttackerMinor, // P2 Take the checker — a humble piece takes the checker
  blockFile, // P3 Block the file — interpose on a vertical lane
  sealDiagonal, // P4 Seal the diagonal — interpose on a diagonal lane
  captureAttackerHeavy, // P5 Win the queen — capture the heavy attacker
  removeDefender, // frontier — no template yet
  forcedInterposition, // frontier — no template yet
  escapeSquare, // deferred (king moves) — no template yet
  // PR-17 Episode 6 — Pin the Threat. The rescue places a long-range
  // friendly piece on a line that connects the enemy attacker to a more
  // valuable enemy piece behind it; the attacker can no longer leave the
  // pin line to deliver its mate.
  pinDefense,
}
