import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_enums.dart';
import '../providers/action_provider.dart';
import '../providers/connection_provider.dart';
import '../providers/game_state_provider.dart';

class JudgementButtons extends ConsumerWidget {
  const JudgementButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(actionNotifierProvider);
    final gameState = ref.watch(gameStateProvider);
    final socketId = ref.read(connectionProvider.notifier).socketId;

    // Only show during judgement phase
    if (gameState.gamePhase != GamePhase.judgement) {
      return const SizedBox.shrink();
    }

    // Disable for the target (the person on the stand cannot vote)
    final isTarget = actionState.judgementTarget == socketId;

    final myVote = actionState.judgementVotes[socketId];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isTarget ? '결과를 기다리는 중...' : '처형하시겠습니까?',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _JudgementButton(
                  label: '찬성',
                  color: Colors.redAccent,
                  isSelected: myVote == 'yes',
                  onPressed: isTarget ? null : () => _vote(ref, 'yes'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _JudgementButton(
                  label: '반대',
                  color: Colors.greenAccent,
                  isSelected: myVote == 'no',
                  onPressed: isTarget ? null : () => _vote(ref, 'no'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _vote(WidgetRef ref, String vote) {
    ref.read(actionNotifierProvider.notifier).sendJudgementVote(vote);
  }
}

class _JudgementButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback? onPressed;

  const _JudgementButton({
    required this.label,
    required this.color,
    required this.isSelected,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : color.withValues(alpha: 0.2),
        foregroundColor: isSelected ? Colors.black : color,
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: isSelected ? 8 : 0,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
