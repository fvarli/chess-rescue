enum GameState { danger, selected, rescued, failed }

extension GameStateX on GameState {
  bool get isPlayable => this == GameState.danger || this == GameState.selected;
}
