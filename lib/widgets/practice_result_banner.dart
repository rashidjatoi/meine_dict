import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PracticeResultBanner extends StatelessWidget {
  const PracticeResultBanner({
    super.key,
    required this.isCorrect,
    required this.correctAnswer,
    this.onContinue,
  });

  final bool isCorrect;
  final String correctAnswer;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCorrect
            ? colors.success.withValues(alpha: 0.12)
            : colors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? colors.success : colors.error,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? colors.success : colors.error,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            isCorrect ? 'Correct!' : 'Not quite',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isCorrect ? colors.success : colors.error,
            ),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 4),
            Text(
              'Answer: $correctAnswer',
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (onContinue != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onContinue,
              child: const Text('Continue'),
            ),
          ],
        ],
      ),
    );
  }
}
