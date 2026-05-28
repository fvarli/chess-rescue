import 'package:flutter/material.dart';

import '../../../core/haptics.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/motion.dart';
import '../game_state.dart';

class FooterButton extends StatefulWidget {
  const FooterButton({
    super.key,
    required this.state,
    required this.label,
    required this.onTap,
  });

  final GameState state;
  final String label;
  final VoidCallback onTap;

  @override
  State<FooterButton> createState() => _FooterButtonState();
}

class _FooterButtonState extends State<FooterButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _inviteBreath;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _inviteBreath = AnimationController(
      vsync: this,
      duration: MotionTokens.buttonInviteBreath,
    );
    _syncBreath();
  }

  @override
  void didUpdateWidget(covariant FooterButton old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) _syncBreath();
  }

  void _syncBreath() {
    if (widget.state == GameState.failed) {
      _inviteBreath.repeat(reverse: true);
    } else {
      _inviteBreath.stop();
      _inviteBreath.value = 0;
    }
  }

  @override
  void dispose() {
    _inviteBreath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRescued = widget.state == GameState.rescued;
    final label = widget.label;
    final pressedScale = _pressed ? MotionTokens.buttonPressedScale : 1.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        Haptics.tapButton();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: _inviteBreath,
        builder: (context, child) {
          final inviteT = MotionTokens.breath.transform(_inviteBreath.value);
          final inviteScale =
              1.0 + (MotionTokens.buttonInviteScaleMax - 1.0) * inviteT;
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(end: pressedScale),
            duration: _pressed
                ? MotionTokens.buttonPressIn
                : MotionTokens.buttonPressOut,
            curve: _pressed ? MotionTokens.press : MotionTokens.standard,
            builder: (context, press, _) {
              return Transform.scale(scale: press * inviteScale, child: child);
            },
          );
        },
        child: SizedBox(
          width: double.infinity,
          child: AnimatedContainer(
            duration: MotionTokens.headlineFade,
            curve: MotionTokens.standard,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isRescued ? AppColors.rescue : Colors.transparent,
              border: Border.all(
                color: isRescued ? Colors.transparent : AppColors.hairline,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isRescued
                  ? [
                      BoxShadow(
                        color: AppColors.rescue.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: AppText.button.copyWith(
                  color: isRescued ? AppColors.onRescue : AppColors.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
