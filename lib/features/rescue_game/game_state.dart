enum GameState { danger, selected, rescued, failed }

extension GameStateX on GameState {
  bool get isResolved => this == GameState.rescued || this == GameState.failed;
  bool get isPlayable => this == GameState.danger || this == GameState.selected;
}
