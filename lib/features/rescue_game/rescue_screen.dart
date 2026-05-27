import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/motion.dart';
import 'game_controller.dart';
import 'game_state.dart';
import 'widgets/board_widget.dart';
import 'widgets/footer_button.dart';
import 'widgets/headline_text.dart';
import 'widgets/status_bar.dart';

class RescueScreen extends StatefulWidget {
  const RescueScreen({super.key});

  @override
  State<RescueScreen> createState() => _RescueScreenState();
}

class _RescueScreenState extends State<RescueScreen> {
  late final GameController _game;

  @override
  void initState() {
    super.initState();
    _game = GameController();
  }

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListenableBuilder(
        listenable: _game,
        builder: (context, _) {
          final isRescued = _game.state == GameState.rescued;
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
                          ? const Color(0xFF0E2A23)
                          : const Color(0xFF1A1C28),
                      AppColors.bg,
                    ],
                    stops: const [0.0, 0.8],
                  ),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final boardSize = c.maxWidth < c.maxHeight - 280
                        ? c.maxWidth - 24
                        : c.maxHeight - 280;
                    final size = boardSize.clamp(240.0, 360.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: StatusBar(
                              state: _game.state,
                              message: _game.statusMsg,
                            ),
                          ),
                          const SizedBox(height: 30),
                          HeadlineText(
                            state: _game.state,
                            hasSelection: _game.selected != null,
                          ),
                          const Spacer(),
                          BoardWidget(
                            size: size,
                            pieces: _game.pieces,
                            selected: _game.selected,
                            legalSquares: _game.legalSquares,
                            state: _game.state,
                            threatenedKing: _game.puzzle.threatenedKing,
                            rescueTo: _game.puzzle.rescueTo,
                            rescueFrom: _game.puzzle.rescueFrom,
                            commitInFlight: _game.commitInFlight,
                            resetInFlight: _game.resetInFlight,
                            onTapSquare: _game.handleSquare,
                          ),
                          const SizedBox(height: 28),
                          HintText(
                            state: _game.state,
                            hasSelection: _game.selected != null,
                          ),
                          const Spacer(),
                          FooterButton(state: _game.state, onTap: _game.reset),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
